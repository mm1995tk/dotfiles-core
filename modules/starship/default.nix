{lib, ...}: {
  programs.starship = {
    enable = true;

    # starship.toml の値は「既定値」として渡し、このモジュールを読み込む側が
    # lib.mkForce なしで上書きできるようにする。見た目は環境ごとに差し替える
    # 前提のものなので、上書きのたびに mkForce を書かせない。
    #
    # mkDefault はセット全体ではなく葉（スカラー）単位で掛ける必要がある。
    # attrs 全体に掛けると読み込み側が settings に何か定義した時点で
    # 優先度の低い定義として丸ごと破棄され、既定値が全部消える。
    settings =
      lib.mapAttrsRecursive
      (_path: value: lib.mkDefault value)
      (fromTOML (builtins.readFile ./starship.toml));
  };
}
