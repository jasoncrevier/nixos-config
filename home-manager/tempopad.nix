{ pkgs, ... }:

let
  synidoScript = pkgs.writeShellScript "synido-autoconnect" ''
    MAC="81:24:24:01:6C:A2"
    HANDSHAKEN=""
    
    while true; do
      if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
        if [ -z "$HANDSHAKEN" ]; then
          sleep 2
          bluetoothctl disconnect "$MAC" >/dev/null 2>&1
          sleep 1
          bluetoothctl connect "$MAC" >/dev/null 2>&1
          HANDSHAKEN="1"
          sleep 2
        fi
        pw-link "Midi-Bridge:Synido TempoPAD C16 BT: Bluetooth (capture)" "Midi-Bridge:Virtual Raw MIDI 2-0:VirMIDI 2-0 (playback)" 2>/dev/null
      else
        HANDSHAKEN=""
      fi
      sleep 3
    done
  '';
in
{
  systemd.user.services.synido-midi-autoconnect = {
    Unit = {
      Description = "Auto-connect and handshake Synido TempoPAD C16";
      After = [ "pipewire.service" "wireplumber.service" "sound.target" "bluetooth.service" ];
      Requires = [ "pipewire.service" ];
    };
    Service = {
      Type = "simple";
      Environment = "PATH=/run/current-system/sw/bin:${pkgs.pipewire}/bin:${pkgs.bluez}/bin:${pkgs.gnugrep}/bin:${pkgs.coreutils}/bin";
      ExecStart = "${synidoScript}";
      Restart = "always";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}