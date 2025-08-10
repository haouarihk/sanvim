-- LazyVim configuration for SanVim plugin
-- Add this to your LazyVim plugins configuration

return {
    {
        "your-username/sanvim", -- Replace with your actual GitHub username/repo
        name = "sanvim",
        description = "GTA San Andreas cheat code sound plugin for Neovim",
        event = "VeryLazy",
        config = function()
            require("sanvim").setup({
                -- Customize these options
                enabled = true,
                min_word_length = 5, -- Minimum word length to trigger sound
                sound_file = nil, -- Custom sound file path (optional)
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
                    -- Add more custom messages here
                }
            })
        end,
        keys = {
            -- Optional: Add keymaps for plugin commands
            { "<leader>st", "<cmd>SanVimToggle<cr>", desc = "Toggle SanVim" },
            { "<leader>sc", "<cmd>SanVimCount<cr>", desc = "Show cheat count" },
            { "<leader>sr", "<cmd>SanVimReset<cr>", desc = "Reset cheat count" },
        },
        dependencies = {
            -- Optional: nvim-notify for better notifications
            "rcarriga/nvim-notify",
        },
        -- Plugin metadata
        author = "Your Name",
        version = "1.0.0",
        license = "MIT",
        homepage = "https://github.com/your-username/sanvim",
        bugs = "https://github.com/your-username/sanvim/issues",
        readme = "https://github.com/your-username/sanvim#readme",
    }
} 