local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- 16 色パレットと背景・前景の実体はここで決める。starship 側は "blue" のような
-- 色名で参照するだけにして、色の定義がふたつに散らないようにしている。
config.color_scheme = "GitHub Dark"

-- 同梱の JetBrains Mono には CJK の字形が無く、フォントを未指定にすると
-- 漢字の描画が OS のフォールバック順任せになる。中国語フォントが先に拾われる
-- マシンでは「実」のような日本語字形が化けるため、次点を明示して固定する。
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Noto Sans Mono CJK JP",
})

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
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

-- GPU/EGL の無い環境（VNC やヘッドレスのコンテナなど）では
-- WEZTERM_FORCE_SOFTWARE=1 でソフトウェア描画に切り替える。
-- これがないとデフォルトの OpenGL front_end が libEGL.so.1 を要求して
-- ウィンドウ生成に失敗する。
if os.getenv("WEZTERM_FORCE_SOFTWARE") == "1" then
	config.front_end = "Software"
end

return config
