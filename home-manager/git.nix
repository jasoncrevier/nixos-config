{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jason Crevier";
        email = "jason@jasoncrevier.com";
      };
    };
    signing = {
      format = null;
    };
    # In this repo, have `git blame` skip the formatting-only commits
    includes = [
      {
        condition = "gitdir:~/nixos-config/";
        contents.blame.ignoreRevsFile = "/home/jason/nixos-config/.git-blame-ignore-revs";
      }
    ];
  };

  # gh handles credentials for github.com only; other hosts prompt as usual
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
