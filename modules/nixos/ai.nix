{ ... }: {
  flake.nixosModules.ai = { pkgs, ... }: {
    # Disabled for now: ollama-cuda + open-webui auto-start at boot and
    # contend with the desktop (niri/noctalia) for CPU/IO, making the shell
    # paint very slowly at login. Re-enable when the local LLM is needed.
    # services.ollama = {
    #   enable = true;
    #   package = pkgs.ollama-cuda; # CUDA build for the nvidia stable driver
    # };

    # services.open-webui = {
    #   enable = true;
    #   host = "127.0.0.1";
    #   port = 9999;
    #   environment = {
    #     OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    #     WEBUI_AUTH = "False"; # single-user local box, skip the login wall
    #     ENABLE_OPENAI_API = "False"; # don't phone OpenAI
    #     ANONYMIZED_TELEMETRY = "False";
    #     DO_NOT_TRACK = "True";
    #   };
    # };
  };
}
