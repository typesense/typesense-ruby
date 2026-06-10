{
  description = "Nix development environment for the Typesense Ruby client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        ruby = pkgs.ruby_3_4;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            ruby
            bundler
            git
            curl
            pkg-config
            openssl
            libyaml
            zlib
            libffi
            docker
            docker-compose
          ];

          shellHook = ''
            export BUNDLE_PATH="$PWD/.bundle"
            export BUNDLE_BIN="$PWD/.bundle/bin"
            export BUNDLE_APP_CONFIG="$PWD/.bundle/config"
            export GEM_HOME="$PWD/.bundle/ruby"
            export PATH="$BUNDLE_BIN:$GEM_HOME/bin:$PATH"

            cat <<'EOF'
            Typesense Ruby dev shell

            First-time setup:
              bundle install

            Common commands:
              bundle exec rubocop
              bundle exec rspec --format documentation

            Integration tests expect Docker to be running.
            EOF
          '';
        };
      });
}
