{pkgs, ...}: {
  home.packages = with pkgs; [
    _1password-cli
    colima
    docker
    docker-buildx
    devcontainer
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ../config/wezterm.lua;
  };
}
