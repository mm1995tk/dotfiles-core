local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.color_scheme = "GitHub Dark"

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.initial_cols = 120
config.initial_rows = 30
config.default_cwd = wezterm.home_dir .. "/workspace"
config.keys = {
	{ key = "\\", mods = "SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "RightArrow", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Right") },
	{ key = "LeftArrow", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Right") },
	{ key = "h", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Up") },
}

return config
