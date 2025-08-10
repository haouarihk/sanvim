# 🎮 SanVim - GTA San Andreas Cheat Code Sound Plugin

Turn your Neovim into GTA San Andreas cheat code mode! This plugin can trigger the iconic "ding" sound in two ways: when you type 5+ character words (word mode) or when you execute 5 complex key combinations within 5 seconds (combo mode), just like entering cheat codes in the game.

## ✨ Features

- 🎵 **Authentic Sound**: Plays the classic GTA San Andreas cheat code sound
- 🔤 **Word Detection**: Triggers on 5+ letter words (configurable)
- ⌨️ **Combo Mode**: Triggers on 5 complex key combinations within 5 seconds
- 🚫 **Text Mode Exclusion**: Combo mode ignores regular typing in insert mode
- 🎯 **Random Messages**: Shows random cheat code messages like "HEALTH RESTORED"
- 📊 **Cheat Counter**: Tracks how many "cheats" you've activated
- 🎛️ **Easy Toggle**: Turn the plugin on/off with commands
- 🔄 **Mode Switching**: Toggle between word mode and combo mode
- 🖥️ **Cross-Platform**: Works on Windows, macOS, and Linux
- 🚀 **LazyVim Ready**: Full LazyVim integration support

## 🚀 Installation

### Option 1: LazyVim (Recommended)

Add this to your LazyVim plugins configuration:

```lua
{
    "your-username/sanvim",
    name = "sanvim",
    event = "VeryLazy",
    config = function()
        require("sanvim").setup({
            enabled = true,
            combo_mode = true, -- Use combo mode by default
            combo_threshold = 5, -- Number of combos needed
            combo_time_window = 5, -- Time window in seconds
            min_word_length = 5, -- For word mode
            -- Customize cheat messages
            cheat_messages = {
                "HEALTH RESTORED",
                "WEAPONS GIVEN", 
                "VEHICLE SPAWNED",
                -- Add more!
            }
        })
    end,
    keys = {
        { "<leader>st", "<cmd>SanVimToggle<cr>", desc = "Toggle SanVim" },
        { "<leader>sc", "<cmd>SanVimCount<cr>", desc = "Show cheat count" },
        { "<leader>sr", "<cmd>SanVimReset<cr>", desc = "Reset cheat count" },
        { "<leader>sm", "<cmd>SanVimMode<cr>", desc = "Toggle combo/word mode" },
        { "<leader>ss", "<cmd>SanVimStatus<cr>", desc = "Show combo status" },
    },
}
```

### Option 2: Automatic Installation (Recommended)

Run the included installation script in Neovim:

```lua
:source install.lua
```

This will automatically:
- Set up the plugin in your Neovim configuration
- Create necessary directories
- Configure LazyVim integration
- Set up keymaps

### Option 3: Manual Installation

1. Clone this repository to your Neovim plugins directory:
```bash
git clone https://github.com/your-username/sanvim ~/.local/share/nvim/site/pack/plugins/start/sanvim
```

2. Add to your `init.lua`:
```lua
require("sanvim").setup()
```

## 🎵 Sound File Setup

**Great news!** The plugin now comes with a built-in GTA San Andreas cheat code sound file in the `assets/` folder. You don't need to download anything!

### Option 1: Use the Built-in Sound (Recommended)

The plugin automatically detects and uses the included `gta-cheat-sound.mp3` file. No configuration needed!

### Option 2: Use Your Own Sound File

If you want to use a different sound, you can specify a custom path:

```lua
require("sanvim").setup({
    sound_file = "/path/to/your/custom_sound.wav"
})
```

### Option 3: Extract from GTA San Andreas

1. Find the cheat code sound in your GTA San Andreas installation
2. Convert it to `.wav` or `.mp3` format
3. Place it in the plugin's assets directory or specify a custom path

### Supported Audio Formats

- **MP3** - Supported on all platforms
- **WAV** - Best compatibility on Windows
- **Other formats** - Supported via ffplay on Linux

## ⚙️ Configuration

### Default Settings

```lua
require("sanvim").setup({
    enabled = true,                    -- Enable/disable the plugin
    min_word_length = 5,              -- Minimum word length to trigger
    sound_file = nil,                 -- Custom sound file path
    volume = 0.5,                     -- Sound volume (0.0 to 1.0)
    cheat_messages = {                -- Random messages to display
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
})
```

### Custom Cheat Messages

Add your own creative messages:

```lua
cheat_messages = {
    "CODING POWERS ACTIVATED",
    "BUGS ELIMINATED",
    "PRODUCTIVITY BOOST",
    "COFFEE INFINITE",
    "DEBUG MODE ON",
    "GIT MASTER UNLOCKED",
    "VIM-FU MASTERED",
    "TERMINAL DOMINATION",
    "CODE COMPILATION SUCCESS",
    "SYNTAX HIGHLIGHTING PERFECT",
}
```

## 🎮 Commands

- `:SanVimToggle` - Toggle the plugin on/off
- `:SanVimCount` - Show total cheat count
- `:SanVimReset` - Reset cheat counter to 0
- `:SanVimMode` - Toggle between combo mode and word mode
- `:SanVimStatus` - Show combo status (combos within time window)

## ⌨️ Keymaps (LazyVim)

- `<leader>st` - Toggle SanVim
- `<leader>sc` - Show cheat count  
- `<leader>sr` - Reset cheat count
- `<leader>sm` - Toggle combo/word mode
- `<leader>ss` - Show combo status

## 🔧 How It Works

### Combo Mode (Default)
1. **Key Combination Tracking**: Monitors complex key combinations (Ctrl+, Alt+, function keys, multi-key sequences)
2. **Time Window**: Tracks combinations within a 5-second sliding window
3. **Threshold Detection**: Triggers when 5 complex combos are executed within the time window
4. **Insert Mode Exclusion**: Regular typing in insert mode doesn't count (avoiding text mode interference)
5. **Sound & Message**: Plays the GTA sound and shows a random cheat message

### Word Mode (Alternative)
1. **Character Tracking**: Tracks every character you type in insert mode
2. **Word Detection**: When you type 5+ consecutive letters, it triggers the cheat
3. **Sound Playback**: Plays the GTA San Andreas "ding" sound
4. **Message Display**: Shows a random cheat code message
5. **Counter**: Increments your total cheat count

## 🎯 Use Cases

### Combo Mode
- **Advanced Users**: Reward skilled Vim navigation and editing
- **Learning**: Encourage use of complex Vim combinations  
- **Focus Sessions**: Trigger sounds during intensive editing workflows
- **Muscle Memory**: Celebrate mastery of keyboard shortcuts

### Word Mode  
- **Coding Sessions**: Get that satisfying "ding" when typing long variable names
- **Documentation**: Hear the sound when writing long words
- **Beginners**: Simple trigger for new Vim users

### Both Modes
- **Gaming Nostalgia**: Relive the GTA San Andreas experience
- **Productivity**: Make editing more fun and engaging
- **Streaming**: Add entertainment value to coding streams

## 🐛 Troubleshooting

### No Sound Playing

1. **Check sound file path**: Ensure the sound file exists and is accessible
2. **Verify permissions**: Make sure Neovim can access the sound file
3. **Test system audio**: Try playing the sound file manually
4. **Check OS compatibility**: Ensure you're using a supported OS

### Windows Issues

- Make sure PowerShell execution policy allows running scripts
- Try using a `.wav` file instead of `.mp3`
- Check Windows Media Player is working

### macOS Issues

- Ensure `afplay` command is available (should be by default)
- Check audio permissions for terminal applications

### Linux Issues

- Install `paplay` (PulseAudio) or `aplay` (ALSA)
- Check audio system configuration

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Add new cheat messages
- Improve sound playback compatibility
- Add new features
- Fix bugs
- Improve documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Rockstar Games for GTA San Andreas
- The Neovim community for inspiration
- All the developers who make coding fun

## 🎵 Sound Credits

The cheat code sound effect is property of Rockstar Games. This plugin is for educational and entertainment purposes only.

---

**Happy coding with that classic GTA feel! 🎮✨** 