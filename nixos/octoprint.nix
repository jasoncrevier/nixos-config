# Enable Octoprint
 
{ config, pkgs, ... }: 

let
  octoprint-creality2xtemperaturereportingfix = pkgs.python3Packages.buildPythonPackage rec {
    pname = "OctoPrint-Creality2xTemperatureReportingFix";
    version = "2020-09-07";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "SimplyPrint";
      repo = "OctoPrint-Creality2xTemperatureReportingFix";
      rev = "master";
      sha256 = "sha256-erTZt8101KaAI3fGThZcNp0wNOwTJBfR1JNw59YXbA0=";
    };

    build-system = [ pkgs.python3Packages.setuptools ];

    doCheck = false;
  };

  octoprint-camerasettings = pkgs.python3Packages.buildPythonPackage rec {
    pname = "OctoPrint-CameraSettings";
    version = "0.3.1";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "The-EG";
      repo = "OctoPrint-CameraSettings";
      rev = "v${version}";
      sha256 = "sha256-R47v4+C/63MhV7/B/D0fB9MpxI/YV0bN5Kpx6eWjQ7E=";
    };

    build-system = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs = [ pkgs.v4l-utils ];

    doCheck = false;
  };
in
{
  services.octoprint = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    plugins = plugins: [
      octoprint-creality2xtemperaturereportingfix
      octoprint-camerasettings
    ];
  };

  users.users.octoprint = {
    extraGroups = [ "video" "dialout" ];
  };

  systemd.services.mjpg-streamer = {
    description = "MJPEG Streamer for OctoPrint Webcam";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      User = "octoprint";
      Group = "video";
      ExecStart = "${pkgs.mjpg-streamer}/bin/mjpg_streamer -i 'input_uvc.so -r 1280x720 -f 60 -d /dev/video0' -o 'output_http.so -w ${pkgs.mjpg-streamer}/share/mjpg-streamer/www -p 8080'";
      Restart = "on-failure";
    };
  };

  environment.systemPackages = [ 
    pkgs.mjpg-streamer 
    pkgs.v4l-utils 
  ];
}
