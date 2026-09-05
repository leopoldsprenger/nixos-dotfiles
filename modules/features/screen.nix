{...}: {
  flake.nixosModules.screen = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Core utilities, capture, and lightweight tools
      slurp
      grim
      hyprpicker
      imagemagick
      zbar
      curl
      jq
      bc
      coreutils
      procps
      xdg-utils
      mpv

      # Lightweight OCR (English, German, Japanese)
      (tesseract.override {enableLanguages = ["eng" "deu" "jpn"];})

      # Recording backends and markup (swappy handles annotations)
      gpu-screen-recorder
      wl-screenrec
      wf-recorder
      swappy
    ];

    environment.sessionVariables = {
      TESSDATA_PREFIX = "${pkgs.tesseract}/share/tessdata";
    };

    # Automatically deploy the swappy configuration profile
    environment.etc."swappy/config".text = ''
      [config]
      save_dir=/home/leo/Pictures/Annotation
      save_filename_format=Annotation_%Y-%m-%d_%H-%M-%S.png
      show_panel=false
      line_size=5
      text_size=20
      text_font=sans-serif
    '';
  };
}
