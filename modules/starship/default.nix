{lib, ...}: {
  programs.starship = {
    enable = true;

    # starship.toml の値は「既定値」として渡し、プロファイル側が lib.mkForce なしで
    # 上書きできるようにする（他モジュールが base の値を変えるときは mkForce、という
    # このリポジトリの通例に対する意図的な例外。見た目はプロファイルごとに差し替える
    # 前提のものなので、上書きのたびに mkForce を書くほうが煩い）。
    #
    # mkDefault はセット全体ではなく葉（スカラー）単位で掛ける必要がある。
    # attrs 全体に掛けるとプロファイルが settings に何か定義した時点で
    # 優先度の低い定義として丸ごと破棄され、既定値が全部消える。
    settings =
      lib.mapAttrsRecursive
      (_path: value: lib.mkDefault value)
      (fromTOML (builtins.readFile ./starship.toml));
  };
}
