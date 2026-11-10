{lib, ...}: {
  flake.modules.nixos.mic-denoise = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.internal.hardware.micDenoise;

    micDenoiseModule = {
      args = {
        "audio.channels" = 1;
        "audio.position" = ["MONO"];
        "audio.rate" = 48000;

        "capture.props" = {
          "node.passive" = true;
          "target.object" = cfg.inputDevice;
        };

        "filter.graph" = {
          links = [
            {
              input = "DeepFilter Mono:Audio In";
              output = "Highpass:Output";
            }
          ];

          nodes = [
            {
              control = {
                "Cutoff Frequency" = 150.0;
                "Stages(2 poles per stage)" = 3;
              };

              label = "highpass_iir";
              name = "Highpass";
              plugin = "${pkgs.ladspaPlugins}/lib/ladspa/highpass_iir_1890.so";
              type = "ladspa";
            }
            {
              control."Attenuation Limit (dB)" = 100.0;
              label = "deep_filter_mono";
              name = "DeepFilter Mono";
              plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
              type = "ladspa";
            }
          ];
        };

        "media.name" = "DeepFilter Noise Canceling Source";
        "node.description" = "DeepFilter Noise Canceling Source";

        "playback.props" = {
          "media.class" = "Audio/Source";
          "node.autoconnect" = false;
          "node.name" = "deepfilter_source";
        };
      };

      name = "libpipewire-module-filter-chain";
    };
  in {
    options.internal.hardware.micDenoise.inputDevice = mkOption {
      description = "PipeWire source node (target.object) to capture the microphone input from.";
      example = "alsa_input.usb-046d_081b_5AAF2850-02.mono-fallback";
      type = types.str;
    };

    config = {
      services.pipewire.extraConfig.pipewire."92-mic-denoise"."context.modules" = [micDenoiseModule];
      systemd.user.services.pipewire.restartTriggers = [(builtins.toJSON micDenoiseModule)];
    };
  };
}
