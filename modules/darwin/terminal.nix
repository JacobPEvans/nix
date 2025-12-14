# Terminal.app Configuration
#
# macOS Terminal.app stores window settings in nested plist structures
# that require PlistBuddy for modification. Standard `defaults write`
# cannot set nested dictionary values.
#
# This module configures the default window size for new Terminal windows.

{ lib, ... }:

{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    # Configure Terminal.app default profile window size
    PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
    PROFILE="Basic"

    # Set columns (180) for the profile
    /usr/libexec/PlistBuddy -c "Set 'Window Settings':$PROFILE:columnCount 180" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add 'Window Settings':$PROFILE:columnCount integer 180" "$PLIST"

    # Set rows (80) for the profile
    /usr/libexec/PlistBuddy -c "Set 'Window Settings':$PROFILE:rowCount 80" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add 'Window Settings':$PROFILE:rowCount integer 80" "$PLIST"

    echo "Terminal.app profile '$PROFILE' configured for 180x80"
  '';
}
