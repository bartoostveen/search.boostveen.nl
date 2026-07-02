{
  inputs,
  ...
}:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.vert-nix.overlays.default
      ];
    };
  };
}
