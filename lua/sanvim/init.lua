local M = {}

-- Configuration defaults
local config = {
    enabled = true,
    min_word_length = 5,
    sound_file = nil, -- Will be set based on OS
    volume = 0.5,
    -- New combo mode settings
    combo_mode = true, -- If true, uses combo detection; if false, uses word detection
    combo_threshold = 5, -- Number of combos needed
    combo_time_window = 5, -- Time window in seconds
    cheat_messages = {
        "HEALTH RESTORED",
        "WEAPONS GIVEN",
        "VEHICLE SPAWNED",
        "WANTED LEVEL CLEARED",
        "INFINITE AMMO",
        "GOD MODE ACTIVATED",
        "SUPER JUMP ENABLED",
        "INVINCIBILITY ON",
        "SPEED BOOST",
        "FLYING CARS",
    }
}

local current_word = ""
local cheat_count = 0

-- Combo tracking variables
local combo_history = {}
local combo_count = 0

-- Get OS-specific sound file path
local function get_default_sound_path()
    -- First try to find the sound in the plugin's assets directory
    local plugin_path = debug.getinfo(1, "S").source:match("@?(.*/)")
    if plugin_path then
        local assets_path = plugin_path .. "../assets/gta-cheat-sound.mp3"
        if vim.fn.filereadable(assets_path) == 1 then
            return assets_path
        end
    end
    
    -- Fallback to user's home directory
    local home = vim.fn.expand("~")
    if vim.fn.has("win32") == 1 then
        return home .. "/AppData/Local/nvim/sanvim/cheat_ding.wav"
    elseif vim.fn.has("macunix") == 1 then
        return home .. "/.config/nvim/sanvim/cheat_ding.wav"
    else
        return home .. "/.config/nvim/sanvim/cheat_ding.wav"
    end
end

-- Play the cheat code sound
local function play_cheat_sound()
    if not config.enabled then return end
    
    local sound_path = config.sound_file or get_default_sound_path()
    local play_cmd
    
    if vim.fn.has("win32") == 1 then
        -- Windows: Try multiple methods for sound playback
        if sound_path:match("%.mp3$") then
            -- For MP3 files, try using Windows Media Player or PowerShell
            if vim.fn.executable("start") == 1 then
                play_cmd = { "cmd", "/c", "start", "wmplayer", sound_path:gsub("/", "\\") }
            else
                play_cmd = { "powershell", "-c", string.format([[
                    Add-Type -AssemblyName System.Windows.Forms
                    $sound = New-Object System.Media.SoundPlayer
                    $sound.SoundLocation = "%s"
                    $sound.Play()
                ]], sound_path:gsub("/", "\\")) }
            end
        else
            -- For WAV files, use PowerShell
            play_cmd = { "powershell", "-c", string.format([[
                Add-Type -AssemblyName System.Windows.Forms
                $sound = New-Object System.Media.SoundPlayer
                $sound.SoundLocation = "%s"
                $sound.Play()
            ]], sound_path:gsub("/", "\\")) }
        end
    elseif vim.fn.has("macunix") == 1 then
        -- macOS: Use afplay (supports MP3)
        play_cmd = { "afplay", sound_path }
    else
        -- Linux: Try multiple audio players
        if vim.fn.executable("paplay") == 1 then
            play_cmd = { "paplay", sound_path }
        elseif vim.fn.executable("aplay") == 1 then
            play_cmd = { "aplay", sound_path }
        elseif vim.fn.executable("mpg123") == 1 then
            -- mpg123 for MP3 files
            play_cmd = { "mpg123", "-q", sound_path }
        elseif vim.fn.executable("ffplay") == 1 then
            -- ffplay for various audio formats
            play_cmd = { "ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", sound_path }
        end
    end
    
    if play_cmd then
        vim.fn.jobstart(play_cmd, { detach = true })
    end
end

-- Show cheat message notification
local function show_cheat_message()
    if not config.enabled then return end
    
    local message = config.cheat_messages[math.random(#config.cheat_messages)]
    cheat_count = cheat_count + 1
    
    -- Use nvim-notify if available, otherwise use echo
    local ok, notify = pcall(require, "notify")
    if ok then
        notify(message, "info", {
            title = "CHEAT ACTIVATED!",
            timeout = 2000,
            render = "minimal"
        })
    else
        -- Fallback to vim.notify or echo
        if vim.notify then
            vim.notify(message, vim.log.levels.INFO, {
                title = "CHEAT ACTIVATED!",
                timeout = 2000
            })
        else
            vim.api.nvim_echo({{"CHEAT: " .. message, "WarningMsg"}}, true, {})
        end
    end
    
    -- Show cheat count in statusline or command line
    vim.api.nvim_echo({{string.format("Total cheats: %d", cheat_count), "Comment"}}, true, {})
end

-- Clean old combo entries outside the time window
local function clean_combo_history()
    local current_time = vim.fn.reltime()
    local cutoff_time = config.combo_time_window
    
    for i = #combo_history, 1, -1 do
        local elapsed = vim.fn.reltimefloat(vim.fn.reltime(combo_history[i]))
        if elapsed > cutoff_time then
            table.remove(combo_history, i)
        end
    end
end

-- Check if a key combination is "complex" (not just regular typing)
local function is_complex_combo(key)
    -- Complex combinations include:
    -- - Ctrl combinations (except Ctrl+[ which is Escape)
    -- - Alt combinations  
    -- - Function keys
    -- - Special keys with modifiers
    -- - Multi-key sequences in normal mode
    
    if key:match("^<C%-") and key ~= "<C-[>" then
        return true
    end
    if key:match("^<A%-") or key:match("^<M%-") then
        return true
    end
    if key:match("^<F%d+>") then
        return true
    end
    if key:match("^<S%-") and not key:match("^<S%-[a-zA-Z]>$") then
        return true
    end
    if key:match("^<D%-") then -- Cmd key on Mac
        return true
    end
    
    -- Specific multi-key sequences (even if already handled in multi-key detection)
    local complex_sequences = {
        "gg", "gw", "gq", "gt", "gT", "g~", "gu", "gU",
        "zz", "zt", "zb", "zf", "zo", "zc", "za", "zr", "zm",
        "dd", "yy", "cc", ">>", "<<", "==",
    }
    
    for _, seq in ipairs(complex_sequences) do
        if key == seq then
            return true
        end
    end
    
    -- Any special key notation
    if key:match("^<.*>$") then
        return true
    end
    
    return false
end

-- Record a combo and check if threshold is reached
local function record_combo(key)
    if not config.combo_mode or not config.enabled then
        return
    end
    
    -- Only track complex combinations
    if not is_complex_combo(key) then
        return
    end
    
    -- Clean old entries
    clean_combo_history()
    
    -- Add new combo with timestamp
    table.insert(combo_history, vim.fn.reltime())
    
    -- Debug output (optional - can be removed later)
    vim.api.nvim_echo({
        {string.format("Combo detected: %s (%d/%d)", key, #combo_history, config.combo_threshold), "Comment"}
    }, false, {})
    
    -- Check if we've reached the threshold
    if #combo_history >= config.combo_threshold then
        play_cheat_sound()
        show_cheat_message()
        
        -- Reset combo history after triggering
        combo_history = {}
    end
end

-- Track typed characters and trigger cheat sound (only in word mode)
function M.on_insert_char_pre()
    if not config.enabled or config.combo_mode then return end
    
    local char = vim.v.char
    if char:match("%a") then
        current_word = current_word .. char
        if #current_word == config.min_word_length then
            play_cheat_sound()
            show_cheat_message()
        end
    else
        current_word = ""
    end
end

-- Global key sequence tracker
local key_sequence = ""
local key_sequence_timer = nil

-- Handle key events for combo detection using vim.on_key
local function on_key_handler(key, typed)
    if not config.enabled or not config.combo_mode then return end
    
    -- Get the current mode to exclude insert mode (text typing)
    local mode = vim.fn.mode()
    if mode == 'i' or mode == 'R' or mode == 'Rv' then
        return -- Skip insert mode - this is "text mode" typing
    end
    
    -- Convert key codes to readable strings
    local keystr = vim.fn.keytrans(key)
    if not keystr or keystr == "" then return end
    
    -- Reset sequence timer
    if key_sequence_timer then
        vim.fn.timer_stop(key_sequence_timer)
    end
    
    -- Add key to current sequence
    key_sequence = key_sequence .. keystr
    
    -- Check for multi-key sequences first
    local multi_key_patterns = {
        "gg", "gw", "gq", "gt", "gT", "g~", "gu", "gU", "g%d+",
        "zz", "zt", "zb", "zf", "zo", "zc", "za", "zr", "zm", "z%d+",
        "dd", "yy", "cc", ">>", "<<", "==", "d%d+", "y%d+", "c%d+"
    }
    
    local sequence_found = false
    for _, pattern in ipairs(multi_key_patterns) do
        if key_sequence:match(pattern .. "$") then
            record_combo(key_sequence:match(pattern .. "$"))
            key_sequence = ""
            sequence_found = true
            break
        end
    end
    
    -- If no multi-key sequence found, check for single complex keys
    if not sequence_found and is_complex_combo(keystr) then
        record_combo(keystr)
    end
    
    -- Reset sequence after a short delay
    key_sequence_timer = vim.fn.timer_start(500, function()
        key_sequence = ""
    end)
end

-- Setup key tracking
local function setup_combo_tracking()
    if not config.combo_mode then return end
    
    -- Use vim.on_key to capture all keystrokes
    vim.on_key(on_key_handler)
end

-- Reset word tracking when leaving insert mode
function M.reset()
    current_word = ""
end

-- Toggle plugin on/off
function M.toggle()
    config.enabled = not config.enabled
    local status = config.enabled and "ENABLED" or "DISABLED"
    vim.api.nvim_echo({{"SanVim: " .. status, "Comment"}}, true, {})
end

-- Get current cheat count
function M.get_cheat_count()
    return cheat_count
end

-- Reset cheat count
function M.reset_cheat_count()
    cheat_count = 0
    vim.api.nvim_echo({{"Cheat count reset to 0", "Comment"}}, true, {})
end

-- Toggle between combo mode and word mode
function M.toggle_mode()
    config.combo_mode = not config.combo_mode
    local mode = config.combo_mode and "COMBO" or "WORD"
    vim.api.nvim_echo({{"SanVim mode: " .. mode, "Comment"}}, true, {})
    
    -- Clear combo history when switching modes
    combo_history = {}
    current_word = ""
end

-- Get combo status
function M.get_combo_status()
    if not config.combo_mode then
        vim.api.nvim_echo({{"Combo mode is disabled. Current mode: WORD", "Comment"}}, true, {})
        return
    end
    
    clean_combo_history()
    local remaining = config.combo_threshold - #combo_history
    vim.api.nvim_echo({
        {string.format("Combo mode: %d/%d combos needed (within %ds)", 
                      #combo_history, config.combo_threshold, config.combo_time_window), "Comment"}
    }, true, {})
end

-- Setup function
function M.setup(opts)
    -- Merge user options with defaults
    if opts then
        for key, value in pairs(opts) do
            config[key] = value
        end
    end
    
    -- Set default sound file if not provided
    if not config.sound_file then
        config.sound_file = get_default_sound_path()
    end
    
    -- Create autocommands and tracking based on mode
    if config.combo_mode then
        -- Combo mode: setup key event tracking
        setup_combo_tracking()
    else
        -- Word mode: track character input
        vim.api.nvim_create_autocmd("InsertCharPre", {
            callback = M.on_insert_char_pre,
            desc = "SanVim: Track characters for cheat sound"
        })
    end
    
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = M.reset,
        desc = "SanVim: Reset word tracking"
    })
    
    -- Create user commands
    vim.api.nvim_create_user_command("SanVimToggle", M.toggle, { desc = "Toggle SanVim cheat sounds" })
    vim.api.nvim_create_user_command("SanVimCount", function() vim.api.nvim_echo({{"Total cheats: " .. cheat_count, "Comment"}}, true, {}) end, { desc = "Show cheat count" })
    vim.api.nvim_create_user_command("SanVimReset", M.reset_cheat_count, { desc = "Reset cheat count" })
    vim.api.nvim_create_user_command("SanVimMode", M.toggle_mode, { desc = "Toggle between combo and word mode" })
    vim.api.nvim_create_user_command("SanVimStatus", M.get_combo_status, { desc = "Show combo status" })
    
    -- Print welcome message
    local mode_desc = config.combo_mode and 
        string.format("Press %d complex key combos within %ds to trigger!", config.combo_threshold, config.combo_time_window) or
        string.format("Type %d+ letter words to hear the cheat sound!", config.min_word_length)
    vim.api.nvim_echo({{"SanVim loaded! " .. mode_desc, "Comment"}}, true, {})
end

return M 