# coder CLI。`coder config-ssh` や VS Code の Coder 拡張が書く ssh の設定を、
# home-manager の生成する ~/.ssh/config とぶつからないように扱う。
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {
      home.packages = [pkgs.coder];

      # coder は既定だと自分の実行ファイルの store パスを ProxyCommand に書き込み、版が上がって
      # GC されると config-ssh をやり直すまで繋がらなくなる。世代をまたいで変わらないパスを渡す。
      home.sessionVariables.CODER_SSH_CONFIG_BINARY_PATH = "${config.home.profileDirectory}/bin/coder";
    }

    # ~/.ssh/config を home-manager が生成しているときだけ。生成していなければ Include も入らない
    # ので、coder の既定どおり ~/.ssh/config に直接書かせる。
    (lib.mkIf config.programs.ssh.enable {
      # `coder config-ssh` の書き込み先は生成物の ~/.ssh/config でなく別のファイルにして、
      # 取り込むだけにする。ファイルが無くても ssh はエラーにしない。
      programs.ssh.includes = ["coder-config"];
      home.sessionVariables.CODER_SSH_CONFIG_FILE = "$HOME/.ssh/coder-config";

      # VS Code の Coder 拡張が接続のたびに ~/.ssh/config へ自分の Include 行を書き戻し、
      # その過程で home-manager のシンボリックリンクを実体ファイルに置き換える。結果として
      # switch のたびに退避が必要になり、退避先の ~/.ssh/config.backup が残っていると
      # activation が止まる。ここで生成物を正本と宣言して退避そのものを無くす。
      # 消えた Include は拡張が次の接続時に書き戻すので実害は無い。
      home.file.".ssh/config".force = true;
    })
  ];
}
