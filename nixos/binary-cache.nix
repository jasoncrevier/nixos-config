# Download builds from nix-server's binary cache (binary-cache-server.nix) before building locally

{ ... }:

{
  nix.settings = {
    substituters = [ "http://nix-server:5000" ];
    trusted-public-keys = [ "nix-server-2:6dq0wyswAvgUVnbLx6L355Eehnojf7lSTzpbP8I4NcY=" ];
    # Give up on the cache quickly when nix-server is off or Tailscale is down
    connect-timeout = 5;
  };
}
