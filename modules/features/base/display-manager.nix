{self, ...}: {
  flake.nixosModules.display-manager = {
    config,
    pkgs,
    lib,
    ...
  }: let
    wallpaper = ../../../resources/wallpapers/red-tori-gate-sunset.jpg;
    cursorTheme = "Bibata-Modern-Ice";
    cursorSize = 16;
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

    mainQml = pkgs.writeText "Main.qml" ''
      import QtQuick
      import QtQuick.Controls

      Rectangle {
        id: root
        width: 1920
        height: 1080
        color: "${colors.bg}"

        readonly property color fg: "${colors.fg}"
        readonly property color accent: "${colors.accent}"
        readonly property color pill: Qt.alpha("${colors.bg}", 0.75)
        readonly property string uiFont: "${uiFont}"

        Image {
          anchors.fill: parent
          source: "background.jpg"
          fillMode: Image.PreserveAspectCrop
        }

        // Clock
        Text {
          id: clock
          anchors.horizontalCenter: parent.horizontalCenter
          y: parent.height * 0.22 - height / 2
          color: root.accent
          font.family: root.uiFont
          font.pixelSize: 56
          font.weight: Font.Light
          text: Qt.formatTime(new Date(), "HH:mm")
          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
          }
        }

        // Password field
        TextField {
          id: pass
          width: 200
          height: 34
          x: (parent.width - width) / 2
          y: parent.height - height - 48
          echoMode: TextInput.Password
          passwordCharacter: "\u25CF"
          placeholderText: "Password"
          placeholderTextColor: Qt.alpha(root.fg, 0.5)
          color: root.fg
          horizontalAlignment: TextInput.AlignHCenter
          verticalAlignment: TextInput.AlignVCenter
          font.family: root.uiFont
          font.pixelSize: text.length > 0 ? 11 : 12
          font.letterSpacing: text.length > 0 ? 6 : 0
          background: Rectangle {
            radius: height / 2
            color: root.pill
            border.width: pass.activeFocus ? 1 : 0
            border.color: root.accent
          }
          Keys.onReturnPressed: sddm.login("${username}", pass.text, sessionModel.lastIndex)
          Keys.onEnterPressed: sddm.login("${username}", pass.text, sessionModel.lastIndex)
          Component.onCompleted: forceActiveFocus()
        }

        // Error message (above the field, since the field is at the bottom)
        Text {
          id: err
          visible: false
          anchors.horizontalCenter: parent.horizontalCenter
          y: pass.y - height - 10
          color: "${colors.error}"
          font.family: root.uiFont
          font.pixelSize: 11
          text: "Login failed"
        }

        // Power buttons, right of the field
        Row {
          x: pass.x + pass.width + 12
          y: pass.y + (pass.height - 34) / 2
          spacing: 8

          Repeater {
            model: [
              { icon: "\uf021", act: 0 },
              { icon: "\uf011", act: 1 }
            ]
            Rectangle {
              width: 34
              height: 34
              radius: width / 2
              color: area.containsMouse ? Qt.alpha(root.accent, 0.25) : root.pill

              Text {
                anchors.centerIn: parent
                text: modelData.icon
                color: area.containsMouse ? root.accent : root.fg
                font.family: root.uiFont
                font.pixelSize: 14
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

    # X11 greeter: most reliable in a VM
    services.xserver.enable = true;

    # Cursor on the bare X root window (before/outside the greeter)
    services.xserver.displayManager.setupCommands = ''
      ${pkgs.xsetroot or pkgs.xorg.xsetroot}/bin/xsetroot -xcf ${cursorPkg}/share/icons/${cursorTheme}/cursors/left_ptr ${toString cursorSize}
    '';

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = false;
      theme = "mango";
      settings = {
        General = {
          # Software rendering avoids the GL crashes; XCURSOR_* makes the
          # sddm user's greeter find the theme in the store
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
          Font = "${uiFont},12";
        };
      };
    };

    environment.systemPackages = [
      sddmTheme
      cursorPkg
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
