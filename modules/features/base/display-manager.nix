{self, ...}: {
  flake.nixosModules.display-manager = {
    config,
    pkgs,
    lib,
    ...
  }: let
    wallpaper = ../../../resources/wallpapers/red-tori-gate-sunset.jpg;
    cursorTheme = "Bibata-Modern-Ice";
    cursorSize = 20;
    username = "leo";
    uiFont = "JetBrainsMono Nerd Font";

    colors = {
      bg = "#181210";
      fg = "#f3d9d0";
      accent = "#f7b3a3";
      error = "#f38ba8";
    };

    metadata = pkgs.writeText "metadata.desktop" ''
      [SddmGreeterTheme]
      Name=Mango
      Author=leo
      Type=sddm-theme
      MainScript=Main.qml
      QtVersion=6
    '';

    # FIX: Using clean replacement arrays avoids the token interpolation bugs inside long multi-line strings
    mainQmlRaw = ''
      import QtQuick
      import QtQuick.Controls

      Rectangle {
        id: root
        color: "@COLOR_BG@"

        readonly property color fg: "@COLOR_FG@"
        readonly property color accent: "@COLOR_ACCENT@"
        readonly property color pill: Qt.alpha("@COLOR_BG@", 0.75)
        readonly property string uiFont: "@UI_FONT@"

        readonly property double scale: root.width / 1920

        Image {
          anchors.fill: parent
          source: "background.jpg"
          fillMode: Image.PreserveAspectCrop
        }

        Text {
          id: clock
          anchors.horizontalCenter: parent.horizontalCenter
          y: parent.height * 0.22 - height / 2
          color: root.accent
          font.family: root.uiFont
          font.pixelSize: Math.round(68 * root.scale)
          font.weight: Font.Light
          text: Qt.formatTime(new Date(), "HH:mm")
          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
          }
        }

        TextField {
          id: pass
          width: Math.round(260 * root.scale)
          height: Math.round(42 * root.scale)
          x: (parent.width - width) / 2
          y: parent.height - height - Math.round(64 * root.scale)
          echoMode: TextInput.Password
          passwordCharacter: "\u25CF"
          placeholderText: "Password"
          placeholderTextColor: Qt.alpha(root.fg, 0.5)
          color: root.fg
          horizontalAlignment: TextInput.AlignHCenter
          verticalAlignment: TextInput.AlignVCenter
          font.family: root.uiFont
          font.pixelSize: text.length > 0 ? Math.round(14 * root.scale) : Math.round(15 * root.scale)
          font.letterSpacing: text.length > 0 ? Math.round(6 * root.scale) : 0
          background: Rectangle {
            radius: height / 2
            color: root.pill
            border.width: pass.activeFocus ? 1 : 0
            border.color: root.accent
          }
          Keys.onReturnPressed: sddm.login("@USERNAME@", pass.text, sessionModel.lastIndex)
          Keys.onEnterPressed: sddm.login("@USERNAME@", pass.text, sessionModel.lastIndex)
          Component.onCompleted: forceActiveFocus()
        }

        Text {
          id: err
          visible: false
          anchors.horizontalCenter: parent.horizontalCenter
          y: pass.y - height - Math.round(12 * root.scale)
          color: "@COLOR_ERROR@"
          font.family: root.uiFont
          font.pixelSize: Math.round(13 * root.scale)
          text: "Login failed"
        }

        Row {
          x: pass.x + pass.width + Math.round(16 * root.scale)
          y: pass.y + (pass.height - Math.round(42 * root.scale)) / 2
          spacing: Math.round(10 * root.scale)

          Repeater {
            model: [
              { icon: "\uf021", act: 0 },
              { icon: "\uf011", act: 1 }
            ]
            Rectangle {
              width: Math.round(42 * root.scale)
              height: Math.round(42 * root.scale)
              radius: width / 2
              color: area.containsMouse ? Qt.alpha(root.accent, 0.25) : root.pill

              Text {
                anchors.centerIn: parent
                text: modelData.icon
                color: area.containsMouse ? root.accent : root.fg
                font.family: root.uiFont
                font.pixelSize: Math.round(18 * root.scale)
              }

              MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                onClicked: modelData.act === 0 ? sddm.reboot() : sddm.powerOff()
              }
            }
          }
        }

        Connections {
          target: sddm
          function onLoginFailed() {
            pass.text = ""
            err.visible = true
            pass.forceActiveFocus()
          }
        }
      }
    '';

    mainQml = pkgs.writeText "Main.qml" (
      builtins.replaceStrings
      ["@COLOR_BG@" "@COLOR_FG@" "@COLOR_ACCENT@" "@COLOR_ERROR@" "@UI_FONT@" "@USERNAME@"]
      [colors.bg colors.fg colors.accent colors.error uiFont username]
      mainQmlRaw
    );

    sddmTheme = pkgs.runCommand "sddm-mango-theme" {} ''
      d=$out/share/sddm/themes/mango
      mkdir -p $d
      cp ${wallpaper} $d/background.jpg
      cp ${metadata} $d/metadata.desktop
      cp ${mainQml} $d/Main.qml
    '';

    cursorPkg = pkgs.bibata-cursors;
  in {
    services.displayManager.ly.enable = false;
    services.greetd.enable = lib.mkForce false;

    services.xserver.enable = true;

    # FIX: Consolidated setup commands targeting X root settings via xrdb and xsetroot cleanly
    services.xserver.displayManager.setupCommands = ''
      ${pkgs.xrdb}/bin/xrdb -merge - <<EOF
      Xcursor.theme: ${cursorTheme}
      Xcursor.size: ${toString cursorSize}
      EOF
      ${pkgs.xsetroot}/bin/xsetroot -xcf ${cursorPkg}/share/icons/${cursorTheme}/cursors/left_ptr ${toString cursorSize}
    '';

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = false;
      theme = "mango";

      # FIX: Correct option for injection
      extraPackages = [cursorPkg];

      settings = {
        General = {
          GreeterEnvironment = lib.concatStringsSep "," [
            "QT_QUICK_BACKEND=software"
            "LIBGL_ALWAYS_SOFTWARE=1"
            "XCURSOR_THEME=${cursorTheme}"
            "XCURSOR_SIZE=${toString cursorSize}"
            "XCURSOR_PATH=${cursorPkg}/share/icons"
          ];
        };
        Theme = {
          CursorTheme = cursorTheme;
          CursorSize = cursorSize;
          Font = "${uiFont},14";
        };
      };
    };

    environment.systemPackages = [
      sddmTheme
      cursorPkg
      pkgs.xrdb
    ];

    fonts.packages = [
      pkgs.jetbrains-mono
      pkgs.nerd-fonts.jetbrains-mono
    ];

    services.displayManager.sessionPackages = [
      ((pkgs.runCommand "mango-custom-session" {} ''
          mkdir -p $out/share/wayland-sessions
          cat << 'EOF' > $out/share/wayland-sessions/mango.desktop
          [Desktop Entry]
          Name=Mango
          Comment=Launch MangoWM
          Exec=${config.programs.mango.package}/bin/mango -c /etc/mango/config.conf
          Type=Application
          EOF
        '')
        // {providedSessions = ["mango"];})
    ];

    programs.mango.addLoginEntry = false;
  };
}
