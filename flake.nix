{
  description = "search.boostveen.nl";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.bartoostveen.nl/ixx"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ixx:MCJOmZ6W4d8cRevKNuZKRIRJjmmQ+85iwqNzRdcx62g="
    ];
    always-allow-substitutes = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    search = {
      url = "github:nuschtos/search";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "authentik-nix/systems";
    };

    # Search scopes

    bart-packages = {
      url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
      };
    };

    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs = {
        flake-compat.follows = "";
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    comin = {
      url = "github:nlewo/comin";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dtomvan-nur-packages = {
      url = "github:dtomvan/nur-packages";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
      };
    };
    hydra = {
      url = "github:NixOS/hydra";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    meshcoretomqtt = {
      url = "github:Cisien/meshcoretomqtt";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    # nix-oci-lock = { # TODO
    #   url = "git+ssh://forgejo@git.bartoostveen.nl/bart/nix-oci-lock.git";
    #   inputs = {
    #     flake-parts.follows = "flake-parts";
    #     nixpkgs.follows = "nixpkgs";
    #     treefmt-nix.follows = "treefmt-nix";
    #   };
    # };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vert-nix = {
      url = "git+https://git.bartoostveen.nl/bart/vert-nix.git?ref=release";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        ./pkgs.nix
      ];

      perSystem =
        {
          pkgs,
          self',
          inputs',
          system,
          ...
        }:

        {
          treefmt = {
            programs.nixfmt.enable = true;
          };

          packages.default = pkgs.callPackage ./package.nix { inherit inputs inputs'; };
          packages.search = self'.packages.default;

          packages.cache-ixx =
            let
              inherit (inputs.search.inputs.ixx.packages.${system}) ixx;
            in
            pkgs.writeShellApplication {
              name = "cache";

              runtimeInputs = [
                pkgs.attic-client
              ];

              text = ''
                if [[ -v ATTIC_TOKEN ]]; then
                  attic login ixx-cache https://attic.bartoostveen.nl "$ATTIC_TOKEN"
                  attic push ixx-cache:ixx ${ixx}
                else
                  attic push ixx ${ixx}
                fi
              '';
            };
        };
    };
}
