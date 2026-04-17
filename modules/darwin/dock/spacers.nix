# Dock Spacer Tiles
#
# Inserts transparent spacer-tile entries after specific app groups in the Dock.
#
# nix-darwin's defaults activation phase rewrites persistent-apps on every rebuild,
# stripping any manually-added spacers. This script runs AFTER that phase
# (deps = ["defaults"]) and re-inserts spacers via PlistBuddy.
#
# Spacers are placed after:
#   - Visual Studio Code   (end of Knowledge/Dev group)
#   - Messages             (end of Communication group)
#   - Antigravity          (end of AI Assistants group)

_:

let
  userConfig = import ../../../lib/user-config.nix;
  inherit (userConfig.user) homeDir;
in
{
  system.activationScripts.dockSpacers = {
    deps = [ "defaults" ];
    text = ''
      set +e
      echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Inserting dock spacers..."

      _dock_plist="${homeDir}/Library/Preferences/com.apple.dock.plist"

      if [ ! -f "$_dock_plist" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Dock plist not found at $_dock_plist — skipping spacers"
      else
        _vscode="${homeDir}/Applications/Home Manager Apps/Visual Studio Code.app"
        _messages="/System/Applications/Messages.app"
        _antigravity="/Applications/Antigravity.app"

        _vscode_idx=-1
        _messages_idx=-1
        _antigravity_idx=-1
        _i=0

        # Walk persistent-apps until PlistBuddy returns an error (end of array)
        while true; do
          _path=$(/usr/libexec/PlistBuddy \
            -c "Print :persistent-apps:$_i:tile-data:file-data:_CFURLString" \
            "$_dock_plist" 2>/dev/null) || break
          case "$_path" in
            "$_vscode")      _vscode_idx=$_i ;;
            "$_messages")    _messages_idx=$_i ;;
            "$_antigravity") _antigravity_idx=$_i ;;
          esac
          _i=$(( _i + 1 ))
        done

        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] App indices — VS Code:$_vscode_idx  Messages:$_messages_idx  Antigravity:$_antigravity_idx"

        # Build list of found indices, then sort descending so each insertion
        # does not shift the positions of earlier targets.
        _raw=""
        [ "$_vscode_idx" -ge 0 ]      && _raw="$_raw $_vscode_idx"
        [ "$_messages_idx" -ge 0 ]    && _raw="$_raw $_messages_idx"
        [ "$_antigravity_idx" -ge 0 ] && _raw="$_raw $_antigravity_idx"

        _inserted=0
        for _idx in $(printf '%s\n' $_raw | sort -rn); do
          _at=$(( _idx + 1 ))
          if /usr/libexec/PlistBuddy -c "Add :persistent-apps:$_at dict" "$_dock_plist" 2>/dev/null; then
            /usr/libexec/PlistBuddy \
              -c "Add :persistent-apps:$_at:tile-type string spacer-tile" \
              "$_dock_plist" 2>/dev/null || true
            _inserted=$(( _inserted + 1 ))
          fi
        done

        if [ "$_inserted" -gt 0 ]; then
          _dock_user="$SUDO_USER"
          if [ -z "$_dock_user" ] || [ "$_dock_user" = "root" ]; then
            _dock_user="$(/usr/bin/stat -f '%Su' /dev/console 2>/dev/null)"
          fi
          echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✓ Inserted $_inserted spacers — restarting Dock as $_dock_user"
          sudo -u "$_dock_user" /usr/bin/killall Dock 2>/dev/null || true
        else
          echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] No spacers inserted (target apps not found in dock plist)"
        fi
      fi
    '';
  };
}
