local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- ランチャーに並べる ssh 先の一覧。ここに直書きせず default.nix が
-- programs.wezterm.sshHosts から ssh-hosts.lua を生成するのは、ホスト名が
-- 環境ごとの事実だから（homelab では manifest.nix が唯一の真実の源になる）。
-- require ではなく config_dir からの dofile なのは、wezterm の package.path が
-- ~/.config/wezterm 固定で、--config-file で別の場所を読ませたときに拾えないため。
-- 生成物が無い環境でも設定全体が落ちないよう pcall で受ける ── ここでの
-- 読み込み失敗は致命傷ではなく、単に項目が増えないだけ。
local ok, ssh_hosts = pcall(dofile, wezterm.config_dir .. "/ssh-hosts.lua")
if not ok then
	ssh_hosts = {}
end

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

-- GUI とシェルの寿命を切り離すための mux サーバ。この中のペインは GUI を終了しても
-- （アップデートやクラッシュで落ちても）走り続ける。
--
-- **起動時には一切触らない。** default_domain も connect_automatically も設定しないのは、
-- どちらも起動を目に見えて遅くするため ── 前者は最初の窓をリモート扱いにして同期し終える
-- まで黒いままにし、後者はサーバが居なければその起動を待つ（数秒かかる）。普段の窓は
-- ローカルで即座に出るのが正しい。mux は下の launch_menu と ALT|SUPER+Enter を
-- 押した瞬間に初めて起動・接続される。
config.unix_domains = { { name = "unix" } }

-- ssh 先はランチャーの項目として持つ。開くのは**ローカル**側 ── つまり GUI を閉じれば
-- その ssh は切れる、普通の端末と同じ挙動にしてある。
--
-- mux サーバ側で開けば GUI を閉じても切れないが、wezterm の窓はローカルか特定の mux か
-- どちらか一方にしか属せず、両者のタブを1つの窓に混ぜられない。そのため ssh を mux 側で
-- 開くと必ず窓がもう1枚立つ。日常的に使う接続でそれを毎回払うのは割に合わない。
-- 残したいものは下の ALT|SUPER+Enter で明示的に mux 側に開く。
--
-- なお、これで守れるのは「GUI を閉じても切れない」までで、回線が切れれば ssh は死ぬ。
-- 接続先のシェルまで残すには接続先に tmux なり wezterm-mux-server なりが要る（tmux と同じ話）。
config.launch_menu = {}
for _, host in ipairs(ssh_hosts) do
	table.insert(config.launch_menu, {
		label = "ssh " .. host,
		args = { "ssh", host },
		-- 既定は CurrentPaneDomain。mux 側のペインから開くとそちらに引きずられるので明示する。
		domain = "DefaultDomain",
	})
end

-- wezterm は ~/.ssh/config から SSH:<host> / SSHMUX:<host> というドメインを自動生成する。
-- 上と同じ名前がランチャーに並び、永続しない方を選んでしまうので消す。加えて SSH: は
-- wezterm 内蔵の ssh 実装 (libssh-rs) を使い、SSHMUX: は接続先に wezterm-mux-server を要求する。
config.ssh_domains = {}

-- unix ドメインに繋いでから action を実行する。未接続のまま spawn すると、接続完了後に
-- 同じ spawn がもう一度走ってタブが2つ開く（接続済みなら1回で済む）。起動時に繋がない
-- 方針（上記）を保ったまま、繋ぐ瞬間を「使おうとした瞬間」に寄せるためのもの。
local function with_unix_domain(action)
	return wezterm.action_callback(function(window, pane)
		local domain = wezterm.mux.get_domain("unix")
		if domain and domain:state() == "Detached" then
			domain:attach()
		end
		window:perform_action(action, pane)
	end)
end

-- ペイン・workspace の操作は ALT|SUPER に寄せてある（どれか1つ覚えれば残りも探せる）。
config.keys = {
	{ key = "\\", mods = "SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "RightArrow", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Right") },
	{ key = "LeftArrow", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Right") },
	{ key = "h", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT|SUPER", action = act.ActivatePaneDirection("Up") },

	-- 分割したまま一時的に1枚に戻す。3分割以上にすると hjkl の移動より先にこれが要る。
	{ key = "z", mods = "ALT|SUPER", action = act.TogglePaneZoomState },
	-- ペインにラベルを振って直接指定する。数が増えると方向キーでの移動より速い。
	{ key = "p", mods = "ALT|SUPER", action = act.PaneSelect({}) },
	{ key = "s", mods = "ALT|SUPER", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	-- リサイズは連打する操作なので、単発のキーではなくモード（key_tables）にする。
	{ key = "r", mods = "ALT|SUPER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	-- 画面に見えている URL・ハッシュ・IP をキーボードだけで選ぶ。198.18.0.10 のような
	-- IP やコミットハッシュを拾うのに効く（マウスでの選択・Cmd+Click の対になる操作）。
	{ key = "Space", mods = "ALT|SUPER", action = act.QuickSelect },

	-- 接続先 (launch_menu の ssh 項目) を選んで新しいタブで開く。既定ではランチャーに
	-- キーが割り当たっておらず、コマンドパレット経由でしか辿り着けないので専用のキーを与える。
	--
	-- ここだけ ALT|SUPER の一族から外れているのは、macOS が Cmd+Option+D を
	-- Dock の表示切り替えとしてシステム全体で握っていて、端末まで届かないため。
	{ key = "d", mods = "SUPER|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },

	-- 「GUI を閉じても残したいもの」をここで開く。長いビルドや docker compose --build 用。
	{
		key = "Enter",
		mods = "ALT|SUPER",
		action = with_unix_domain(act.SpawnCommandInNewTab({ domain = { DomainName = "unix" } })),
	},

	-- workspace = タブ群まるごとの切り替え単位。関心事ごとに机を分けるためのもの。
	{ key = "w", mods = "ALT|SUPER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "n",
		mods = "ALT|SUPER",
		action = act.PromptInputLine({
			description = "新しい workspace の名前",
			action = wezterm.action_callback(function(window, pane, line)
				if line and line ~= "" then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},

	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

-- 右上に mux 側の状態を出す。プロンプト（starship）が「どのホストに居るか」を示すのに対し、
-- こちらは wezterm 自身しか知らない状態 ── どの workspace に居て、このペインがどのドメインの
-- ものか。色は端末と二重に持たないよう、パレットの色名 (AnsiColor) で参照する。
--
-- one_shot でないキーテーブル（リサイズモード）は、抜け忘れると打鍵が全部そちらに吸われて
-- 「キーボードが壊れた」ように見えるので、入っていることが必ず見えるようにしておく。
wezterm.on("update-right-status", function(window, pane)
	-- 窓やペインを閉じた直後にもこのイベントは走り、既に mux から消えた相手に触ると
	-- 例外になる。ステータスが一度更新されないだけで実害は無いので、丸ごと握りつぶす。
	pcall(function()
		local parts = {}

		local key_table = window:active_key_table()
		if key_table then
			table.insert(parts, { Foreground = { AnsiColor = "Yellow" } })
			table.insert(parts, { Text = " " .. key_table .. " " })
		end

		-- local / unix はどちらも手元のマシンなので出さない。出す価値があるのは
		-- 「このペインだけ別のホストに繋がっている」ことが分かる場合だけ。
		local domain = pane:get_domain_name()
		if domain ~= "local" and domain ~= "unix" then
			table.insert(parts, { Foreground = { AnsiColor = "Aqua" } })
			table.insert(parts, { Text = " " .. domain .. " " })
		end

		table.insert(parts, { Foreground = { AnsiColor = "Fuchsia" } })
		table.insert(parts, { Text = " " .. window:active_workspace() .. " " })

		window:set_right_status(wezterm.format(parts))
	end)
end)

-- wezterm の既定でリンクを開くのは「修飾なしの左クリック」で、SUPER には Up の割り当てが
-- 無いため Cmd+Click は無反応になる。macOS 側の慣習（Safari や他の端末）に合わせて足す。
-- 既定の割り当ては消えないので、無修飾クリックでも従来どおり開ける。
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = act.OpenLinkAtMouseCursor,
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
