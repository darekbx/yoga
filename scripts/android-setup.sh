function download() {
  if hash curl 2>/dev/null; then
    curl -L -o $2 $1
  elif hash wget 2>/dev/null; then
    wget -O $2 $1
  else
    echo >&2 "No supported download tool installed. Please get either wget or curl."
    exit
  fi
}

function installsdk() {
  PROXY_ARGS=""
  if [[ ! -z "$https_proxy" ]]; then
    PROXY_HOST="$(cut -d : "$https_proxy" -f 1,1)"
    PROXY_PORT="$(cut -d : "$https_proxy" -f 2,2)"
    PROXY_ARGS="--proxy=http --proxy_host=$PROXY_HOST --proxy_port=$PROXY_PORT"
  fi

  yes | "$ANDROID_HOME/tools/bin/sdkmanager" $PROXY_ARGS $@
}

function installAndroidSDK {
  export ANDROID_HOME=$HOME/android-sdk
  export ANDROID_NDK_REPOSITORY=$HOME/android-ndk
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"

  if [[ ! -f "$ANDROID_HOME/tools/bin/sdkmanager" ]]; then
    TMP=/tmp/sdk$$.zip
    download 'https://dl.google.com/android/repository/sdk-tools-darwin-3859397.zip' $TMP
    unzip -qod "$ANDROID_HOME" "$TMP"
    rm $TMP
  fi

  if [[ ! -d "$ANDROID_NDK_REPOSITORY/android-ndk-r15c" ]]; then
    TMP=/tmp/ndk$$.zip
    mkdir -p "$ANDROID_NDK_REPOSITORY"
    download 'https://dl.google.com/android/repository/android-ndk-r15c-linux-x86_64.zip' $TMP
    unzip -qod "$ANDROID_NDK_REPOSITORY" "$TMP"
    rm $TMP
  fi

  mkdir -p "$ANDROID_HOME/licenses/"
  echo > "$ANDROID_HOME/licenses/android-sdk-license"
  echo -n 8933bad161af4178b1185d1a37fbf41ea5269c55 >> "$ANDROID_HOME/licenses/android-sdk-license"

  installsdk 'build-tools;23.0.2' 'build-tools;25.0.2' 'build-tools;25.0.1' 'platform-tools' 'platforms;android-23' 'platforms;android-25' 'extras;android;m2repository'
}
