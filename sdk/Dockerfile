FROM ubuntu:24.04

LABEL org.opencontainers.image.source=https://github.com/meyeroppelt/docker-images-flutter

USER root

# android install

ENV ANDROID_HOME=/opt/android-sdk-linux \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

ENV ANDROID_SDK_ROOT=$ANDROID_HOME \
    PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

# comes from https://developer.android.com/studio/#command-line-tools-only
ENV ANDROID_SDK_TOOLS_VERSION 11076708

RUN set -o xtrace \
    && cd /opt \
    && apt-get update \
    && apt-get install -y jq \
    && apt-get install -y openjdk-17-jdk \
    && apt-get install -y sudo wget zip unzip git openssh-client curl bc software-properties-common build-essential ruby-full ruby-bundler libstdc++6 libpulse0 libglu1-mesa locales lcov libsqlite3-dev --no-install-recommends \
    # for x86 emulators
    && apt-get install -y libxtst6 libnss3-dev libnspr4 libxss1 libasound2t64 libatk-bridge2.0-0 libgtk-3-0 libgdk-pixbuf2.0-0 \
    && apt-get install -y -qq xxd \
    && apt-get install -y lftp \
    && apt-get install -qq -y sqlite3 libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && sh -c 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen' \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O android-sdk-tools.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && chown -R root:root $ANDROID_HOME \
    && rm android-sdk-tools.zip \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && yes | sdkmanager --licenses \
    && wget -O /usr/bin/android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator \
    && chmod +x /usr/bin/android-wait-for-emulator \
    && touch /root/.android/repositories.cfg \
    && sdkmanager platform-tools \
    && mkdir -p /root/.android \
    && touch /root/.android/repositories.cfg

# emulator is not available on linux/arm64 (https://issuetracker.google.com/issues/227219818)
RUN if [ $(uname -m) == "x86_64" ]; then sdkmanager emulator ; fi

# android sdk install

RUN yes | sdkmanager \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "platforms;android-33" \
    "platforms;android-32" \
    "platforms;android-31"

ENV ANDROID_NDK_VERSION 27.2.12479018

RUN yes | sdkmanager "ndk;$ANDROID_NDK_VERSION"

# cmake install

RUN mkdir -p /opt/cmake && \
    curl -sSL https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.tar.gz \
    | tar --strip-components=1 -xz -C /opt/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

ENV PATH="/opt/cmake/bin:$PATH"

# flutter install

ARG flutter_version

ENV FLUTTER_HOME=${HOME}/sdks/flutter \
    FLUTTER_VERSION=$flutter_version
ENV FLUTTER_ROOT=$FLUTTER_HOME

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN yes | flutter doctor --android-licenses \
    && flutter doctor \
    && chown -R root:root ${FLUTTER_HOME}

RUN flutter precache --android
