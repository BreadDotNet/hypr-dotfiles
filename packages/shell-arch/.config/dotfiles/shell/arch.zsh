# Arch paths are optional because package installation is a separate operation.
[[ -r /usr/share/nvm/nvm.sh ]] && source /usr/share/nvm/nvm.sh
[[ -r /usr/share/nvm/bash_completion ]] && source /usr/share/nvm/bash_completion

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
path+=("$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools")
[[ -x /usr/bin/google-chrome-stable ]] && export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
