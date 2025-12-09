# Claude Code Statusline - Theme Configuration
#
# Theme selection and custom color definitions.
# Available themes: "classic", "garden", "catppuccin", "custom"
{
  # Active theme
  theme = {
    name = "catppuccin";

    # Theme inheritance - extend base themes with overrides
    inheritance = {
      enabled = true;
      base_theme = "";
      override_colors = [ ];
      merge_strategy = "override";
    };
  };

  # Custom colors (only used when theme.name = "custom")
  colors = {
    # Basic ANSI colors (most compatible)
    basic = {
      red = "\\033[31m";
      blue = "\\033[34m";
      green = "\\033[32m";
      yellow = "\\033[33m";
      magenta = "\\033[35m";
      cyan = "\\033[36m";
      white = "\\033[37m";
    };

    # Extended colors (256-color)
    extended = {
      orange = "\\033[38;5;208m";
      light_orange = "\\033[38;5;215m";
      light_gray = "\\033[38;5;248m";
      bright_green = "\\033[92m";
      purple = "\\033[95m";
      teal = "\\033[38;5;73m";
      gold = "\\033[38;5;220m";
      pink_bright = "\\033[38;5;205m";
      indigo = "\\033[38;5;105m";
      violet = "\\033[38;5;99m";
      light_blue = "\\033[38;5;111m";
    };

    # Text formatting
    formatting = {
      dim = "\\033[2m";
      italic = "\\033[3m";
      strikethrough = "\\033[9m";
      reset = "\\033[0m";
    };
  };

  # Model emojis
  emojis = {
    opus = "🧠";
    haiku = "⚡";
    sonnet = "🎵";
    default_model = "🤖";
    clean_status = "✅";
    dirty_status = "📁";
    clock = "🕐";
    live_block = "🔥";
  };
}
