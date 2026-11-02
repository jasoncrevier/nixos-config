# Nextcloud task lists mirrored locally, for todoman and Claude's to-do workflow.
#
#   vdirsyncer sync                       pull/push changes with Nextcloud
#   todo list                             browse and edit tasks from the terminal
#   tasks-bridge snapshot | apply FILE    used by Claude to read and change tasks
#
# First run on each machine: `vdirsyncer discover` (answer "y" to create the
# local folders), then `vdirsyncer metasync` and `vdirsyncer sync`.

{
  config,
  osConfig,
  pkgs,
  ...
}:

let
  tasks-bridge = pkgs.writers.writePython3Bin "tasks-bridge" {
    libraries = [ pkgs.python3Packages.icalendar ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ../scripts/tasks-bridge.py);
in
{
  accounts.calendar = {
    basePath = "${config.xdg.dataHome}/calendars";

    accounts.nextcloud = {
      remote = {
        type = "caldav";
        url = "https://nextcloud.nullvoid.club/remote.php/dav";
        userName = "jason";
        passwordCommand = [
          "cat"
          osConfig.sops.secrets.nextcloud_tasks_password.path
        ];
      };

      local = {
        type = "filesystem";
        fileExt = ".ics";
      };

      vdirsyncer = {
        enable = true;
        # Every list on the server, including ones added later in Tasks.org
        collections = [
          "from a"
          "from b"
        ];
        # Tasks only; calendar events stay on the server
        itemTypes = [ "VTODO" ];
        metadata = [
          "displayname"
          "color"
        ];
        # A sync always starts with a pull, so the server's copy is the newer one
        conflictResolution = "remote wins";
      };
    };
  };

  programs.vdirsyncer.enable = true;

  programs.todoman = {
    enable = true;
    glob = "nextcloud/*";
    extraConfig = ''
      date_format = "%Y-%m-%d"
      time_format = "%H:%M"
      humanize = True
    '';
  };

  home.packages = [ tasks-bridge ];
}
