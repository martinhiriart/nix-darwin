{
  description = "macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # pkgs.neovim
          pkgs.mkalias
          # pkgs.tmux
          # pkgs.alacritty
          # pkgs.raycast
          # pkgs.powershell
          # pkgs.helix
          pkgs.nixd
          pkgs.nil
        ];

        homebrew = {
          enable = true;
          brews = [
            # dev
            "git"
            "go"
            "vhs"
            "ffmpeg"
            "nvim"
            "ttyd"
            "luarocks"

            # tools
            "chezmoi"
            "fzf"
            "lazygit"
            "ollama"
            "starship"
            "tmux"

            # learning
            "exercism"
            "mas"
            "lazygit"
            "ripgrep"
            "wget"
          ];
          casks = [
            # productivity
            "1password"
            "clickup"
            "google-chrome"
            "google-drive"
            "obsidian"
            "raycast"
            "slack"

            # dev
            "ghostty"
            "httpie"
            "powershell"
            "zed"

            # utils
            "bartender"
            "cloudflare-warp"
            "elgato-camera-hub"
            "elgato-control-center"
            "elgato-stream-deck"
            "ente-auth"
            "shottr"
            "yubico-authenticator"

            # misc
            "affinity-designer"
            "discord"
            "font-caskaydia-cove-nerd-font"
            "font-jetbrains-mono-nerd-font"
            "font-geist-mono-nerd-font"
          ];
          masApps = {
            # "Tailscale" = 1475387142;
          };
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

      security.pam.enableSudoTouchIdAuth = true;

      system.defaults = {
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
      };

      # Auto upgrade nix package and the daemon service
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      programs.direnv.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "martin";
            autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."macbook".pkgs;
  };
}
