{
  inputs,
  inputs',
  lib,
  nixosOptionsDoc,
  jq,
  runCommand,
  pkgs,
}:

let
  inherit (lib) getExe;

  includePkgs = {
    _module.args = { inherit pkgs; };
  };
in
inputs'.search.packages.mkMultiSearch {
  scopes = [
    {
      modules = [
        inputs.authentik-nix.nixosModules.default
        includePkgs
      ];
      name = "authentik-nix";
      pkgs = inputs'.authentik-nix.packages;
      urlPrefix = "https://github.com/nix-community/authentik-nix/blob/main/";
    }
    {
      modules = [ inputs.comin.nixosModules.comin ];
      name = "comin";
      pkgs = inputs'.comin.packages;
      urlPrefix = "https://github.com/nlewo/comin/blob/main/";
    }
    {
      name = "copyparty";
      urlPrefix = "https://github.com/9001/copyparty/blob/hovudstraum/";
      modules = [ inputs.copyparty.nixosModules.default ];
    }
    {
      modules = [ inputs.disko.nixosModules.default ];
      name = "disko";
      pkgs = inputs'.disko.packages;
      specialArgs.modulesPath = inputs.nixpkgs + "/nixos/modules";
      urlPrefix = "https://github.com/nix-community/disko/blob/master/";
    }
    {
      optionsJSON =
        inputs'.home-manager.packages.docs-html.passthru.home-manager-options.nixos.json
        + /share/doc/nixos/options.json;
      name = "Home Manager (NixOS)";
      urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
    }
    {
      optionsJSON = inputs'.home-manager.packages.docs-json + /share/doc/home-manager/options.json;
      optionsPrefix = "home-manager.users.<name>";
      name = "Home Manager (Standalone)";
      urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
    }
    {
      modules = [
        inputs.meshcoretomqtt.nixosModules.default
        includePkgs
      ];
      name = "Meshcore to MQTT";
      urlPrefix = "https://github.com/Cisien/meshcoretomqtt/blob/main/";
    }
    {
      name = "plasma-manager";
      urlPrefix = "https://github.com/nix-community/plasma-manager/blob/main/";
      optionsJSON =
        let
          eval = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              inputs.plasma-manager.homeModules.plasma-manager
              {
                home.stateVersion = "26.11";
                home.username = "someuser";
                home.homeDirectory = "/home/someuser";
              }
            ];
          };
          doc = nixosOptionsDoc {
            inherit (eval) options;
            warningsAreErrors = false;
          };
        in
        runCommand "options-filtered" { } ''
          ${getExe jq} 'to_entries | map(select(.key | startswith("programs.plasma"))) | from_entries' ${doc.optionsJSON}/share/doc/nixos/options.json > $out
        '';
    }
    {
      modules = [
        inputs.simple-nixos-mailserver.nixosModules.default
        # based on https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/290a995de5c3d3f08468fa548f0d55ab2efc7b6b/flake.nix#L61-73
        {
          mailserver = {
            fqdn = "mx.example.com";
            domains = [ "example.com" ];
            dmarcReporting = {
              organizationName = "Example Corp";
              domain = "example.com";
            };
          };
        }
      ];
      name = "simple-nixos-mailserver";
      pkgs = inputs'.simple-nixos-mailserver.packages;
      urlPrefix = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/master/";
    }
    {
      modules = [ inputs.sops-nix.nixosModules.default ];
      name = "sops-nix";
      pkgs = inputs'.sops-nix.packages;
      urlPrefix = "https://github.com/Mic92/sops-nix/blob/master/";
    }
    {
      modules = [
        inputs.vert-nix.nixosModules.default
        includePkgs
      ];
      name = "vert-nix";
      pkgs = inputs'.vert-nix.packages;
      urlPrefix = "https://git.bartoostveen.nl/bart/vert-nix/src/branch/release/";
      specialArgs.modulesPath = inputs.nixpkgs + "/nixos/modules";
    }
  ];
}
