{cfg}: {
  config,
  lib,
  name,
  ...
}: let
  inherit (lib) literalExpression mkOption types;
in {
  options = {
    hostName = mkOption {
      type = types.str;
      default = name;
      description = "Canonical hostname for the server.";
    };

    serverAliases = mkOption {
      type = with types; listOf str;
      default = [];
      example = ["www.example.org" "example.org"];
      description = ''
        Additional names of virtual hosts served by this virtual host configuration.
      '';
    };

    listenAddresses = mkOption {
      type = with types; listOf str;
      description = ''
        A list of host interfaces to bind to for this virtual host.
      '';
      default = [];
      example = ["127.0.0.1" "::1"];
    };

    useACMEHost = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        A host of an existing Let's Encrypt certificate to use.
        This is mostly useful if you use DNS challenges but Caddy does not
        currently support your provider.

        *Note that this option does not create any certificates, nor
        does it add subdomains to existing ones – you will need to create them
        manually using [](#opt-security.acme.certs).*
      '';
    };

    logFormat = mkOption {
      type = types.lines;
      default = ''
        output file ${cfg.logDir}/access-${config.hostName}.log
      '';
      defaultText = ''
        output file ''${config.services.caddy.logDir}/access-''${hostName}.log
      '';
      example = literalExpression ''
        mkForce '''
          output discard
        ''';
      '';
      description = ''
        Configuration for HTTP request logging (also known as access logs). See
        <https://caddyserver.com/docs/caddyfile/directives/log#log>
        for details.
      '';
    };

    reverseProxy = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Option to give the parameters to a simple "reverse_proxy" command
        appended after extraConfig.
      '';
    };

    subDomains = mkOption {
      type = types.attrsOf (types.submodule (import ./sub-domain-options.nix {inherit cfg;}));
      default = {};
      example = literalExpression ''
        {
          headscale = {
            reverseProxy = "localhost:8080";
            extraConfig = '''
              encode gzip
            ''';
          }
        };
      '';
      description = ''
        Declarative specification of a virtual hosts subdomain served by Caddy.
      '';
    };

    subDirectories = mkOption {
      type = types.attrsOf (types.submodule (import ./sub-dir-options.nix {inherit cfg;}));
      default = {};
      example = literalExpression ''
        {
          headscale = {
            appSupport = false;
            reverseProxy = "localhost:8080";
            extraConfig = '''
              encode gzip
            ''';
          };
        };
      '';
      description = ''
        Declarative specification of a subdomain's subdirectories served by Caddy.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional lines of configuration appended to this virtual host in the
        automatically generated `Caddyfile`.
      '';
    };
  };
}
