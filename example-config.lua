-- Example SanVim configuration
-- Copy this to your Neovim config and customize as needed

-- Basic setup
require("sanvim").setup()

-- Advanced setup with custom options
require("sanvim").setup({
    enabled = true,
    
    -- Combo mode settings (NEW!)
    combo_mode = true, -- Set to false for word mode
    combo_threshold = 5, -- Number of complex combos needed
    combo_time_window = 5, -- Time window in seconds
    
    -- Word mode settings
    min_word_length = 5, -- Change to 4 for more frequent triggers (word mode only)
    
    -- Custom sound file path (optional)
    -- The plugin automatically uses the included gta-cheat-sound.mp3
    -- Uncomment below to use a custom sound file instead:
    -- sound_file = "C:/Users/YourName/Downloads/custom_cheat_sound.wav",
    
    -- Custom cheat messages
    cheat_messages = {
        -- GTA San Andreas classics
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
        
        -- Coding-themed messages
        "BUGS ELIMINATED",
        "PRODUCTIVITY BOOST",
        "DEBUG MODE ON",
        "CODE COMPILATION SUCCESS",
        "SYNTAX HIGHLIGHTING PERFECT",
        "GIT MASTER UNLOCKED",
        "VIM-FU MASTERED",
        "TERMINAL DOMINATION",
        "COFFEE INFINITE",
        "CODING POWERS ACTIVATED",
        
        -- Fun messages
        "PIZZA DELIVERED",
        "CAT PETTED",
        "KEYBOARD CLEANED",
        "DESK ORGANIZED",
        "BRAIN BOOSTED",
        "MOTIVATION RESTORED",
        "CREATIVITY UNLOCKED",
        "FOCUS MODE ON",
        "DISTRACTIONS CLEARED",
        "SUCCESS GUARANTEED",
    }
})

-- Optional: Add keymaps for easy access
vim.keymap.set("n", "<leader>st", "<cmd>SanVimToggle<cr>", { desc = "Toggle SanVim" })
vim.keymap.set("n", "<leader>sc", "<cmd>SanVimCount<cr>", { desc = "Show cheat count" })
vim.keymap.set("n", "<leader>sr", "<cmd>SanVimReset<cr>", { desc = "Reset cheat count" })
vim.keymap.set("n", "<leader>sm", "<cmd>SanVimMode<cr>", { desc = "Toggle combo/word mode" })
vim.keymap.set("n", "<leader>ss", "<cmd>SanVimStatus<cr>", { desc = "Show combo status" })

-- Optional: Auto-disable in certain file types
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
        -- Disable SanVim in text-heavy files to avoid spam
        require("sanvim").setup({ enabled = false })
    end,
})

-- Optional: Re-enable when leaving those file types
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua", "vim", "python", "javascript", "typescript" },
    callback = function()
        -- Re-enable SanVim in code files
        require("sanvim").setup({ enabled = true })
    end,
}) 