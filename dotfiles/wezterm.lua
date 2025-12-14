local wezterm = require 'wezterm'

config = wezterm.config_builder()

config.launch_menu = {
    {
        label = 'bottom',
        args = { '/Users/kstrand/.cargo/bin/btm' },
    },
    {
        label = 'Bash',
        args = { '/opt/homebrew/bin/bash', '-l' },
    },
    {
        label = 'Nushell',
        args = { '/Users/kstrand/.cargo/bin/nu' },
    },
    {
        label = 'Bash3',
        args = { '/bin/bash', '--norc' },
    },
}

config.color_scheme = "Tango (terminal.sexy)"

config.keys = {
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnCommandInNewTab { cwd=wezterm.home_dir } },
  { key = 'n', mods = 'CMD', action = wezterm.action.SpawnCommandInNewWindow { cwd=wezterm.home_dir } },
}

config.tab_bar_at_bottom = true
-- Hopefully this lets the system close WezTerm non-interactively, e.g. when restarting the computer
config.window_close_confirmation = 'NeverPrompt'

-- taken from https://github.com/wez/wezterm/issues/3803#issuecomment-1608954312
config.hyperlink_rules = {
  -- Matches: a URL in parens: (URL)
  {
    regex = '\\((\\w+://\\S+)\\)',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in brackets: [URL]
  {
    regex = '\\[(\\w+://\\S+)\\]',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in curly braces: {URL}
  {
    regex = '\\{(\\w+://\\S+)\\}',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in angle brackets: <URL>
  {
    regex = '<(\\w+://\\S+)>',
    format = '$1',
    highlight = 1,
  },
  -- Then handle URLs not wrapped in brackets
  {
    -- Before
    --regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
    --format = '$0',
    -- After
    regex = '[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)',
    format = '$1',
    highlight = 1,
  },
  -- implicit mailto link
  {
    regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
    format = 'mailto:$0',
  },
}

-- Make sure the window border doesn't disappear against a black background
config.window_frame = {
  border_left_width = '0.2cell',
  border_right_width = '0.2cell',
  border_bottom_height = '0.1cell',
  border_left_color = 'grey',
  border_right_color = 'grey',
  border_bottom_color = 'grey',
}

config.selection_word_boundary = " \t\n{}[]()\"'`*&^%$#@!:"

return config
