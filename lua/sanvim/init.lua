local M = {}

-- Configuration defaults
local config = {
    enabled = true,
    min_word_length = 5,
    sound_file = nil, -- Will be set based on OS
    volume = 0.5,
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

-- Track typed characters and trigger cheat sound
function M.on_insert_char_pre()
    if not config.enabled then return end
    
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
    
    -- Create autocommands
    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = M.on_insert_char_pre,
        desc = "SanVim: Track characters for cheat sound"
    })
    
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = M.reset,
        desc = "SanVim: Reset word tracking"
    })
    
    -- Create user commands
    vim.api.nvim_create_user_command("SanVimToggle", M.toggle, { desc = "Toggle SanVim cheat sounds" })
    vim.api.nvim_create_user_command("SanVimCount", function() vim.api.nvim_echo({{"Total cheats: " .. cheat_count, "Comment"}}, true, {}) end, { desc = "Show cheat count" })
    vim.api.nvim_create_user_command("SanVimReset", M.reset_cheat_count, { desc = "Reset cheat count" })
    
    -- Print welcome message
    vim.api.nvim_echo({{"SanVim loaded! Type " .. config.min_word_length .. "+ letter words to hear the cheat sound!", "Comment"}}, true, {})
end

return M 