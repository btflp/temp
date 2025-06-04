#!/bin/bash
sudo apt update
sudo apt install -y openjdk-17-jdk ripgrep
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

if [ ! -d "/tmp/android-sdk" ]; then
        mkdir /tmp/android-sdk
        wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip
        mkdir -p /tmp/android-sdk/cmdline-tools
        unzip commandlinetools.zip -d /tmp/android-sdk/cmdline-tools
        rm commandlinetools.zip
    yes | /tmp/android-sdk/cmdline-tools/cmdline-tools/bin/sdkmanager --sdk_root=$(realpath /tmp/android-sdk/) --install "platform-tools" "cmdline-tools;latest" "ndk;23.2.8568313"
    if [ -d "/tmp/android-sdk/cmdline-tools/latest" ]; then
        rm -rf /tmp/android-sdk/cmdline-tools/cmdline-tools
    fi
fi

if [ ! -d "/workspaces/temp/android" ]; then
    curl https://storage.googleapis.com/git-repo-downloads/repo > ./repo
    chmod a+x ./repo
    ./repo init -u https://github.com/osmandapp/OsmAnd-manifest -m readonly.xml
    ./repo sync

    cd /workspaces/temp/android
    sed -e 's#storeFile file("/var/lib/jenkins/osmand_key")#storeFile file("../keystores/debug.keystore")#' \
    -e 's#storePassword System.getenv("OSMAND_APK_PASSWORD")#storePassword "android"#' \
    -e 's#storePassword System.getenv("OSMAND_APK_PASSWORD")#storePassword "android"#' \
    -e 's#keyAlias "osmand"#keyAlias "androiddebugkey"#' \
    -e 's#keyPassword System.getenv("OSMAND_APK_PASSWORD")#keyPassword "android"#' \
    OsmAnd/build.gradle > OsmAnd/build.gradle.neu
    mv OsmAnd/build.gradle.neu OsmAnd/build.gradle    
fi

cd /workspaces/temp/android

#git ../patch_7dd385fd62.diff
JAVA_TOOL_OPTIONS=' -Xmx10g' JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 PATH=$JAVA_HOME/bin:$PATH ANDROID_HOME=/tmp/android-sdk PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin ./gradlew assembleAndroidFullLegacyArm64
JAVA_TOOL_OPTIONS=' -Xmx10g' JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 PATH=$JAVA_HOME/bin:$PATH ANDROID_HOME=/tmp/android-sdk PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin ./gradlew assembleAndroidFullLegacyArmv7

exit 0
