FROM eclipse-temurin:17-jdk

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    libglu1-mesa \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT && \
    cd $ANDROID_SDK_ROOT && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q commandlinetools-linux-11076708_latest.zip && \
    rm commandlinetools-linux-11076708_latest.zip && \
    mv cmdline-tools tools && \
    mkdir -p cmdline-tools && \
    mv tools cmdline-tools/

ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Accept Android licenses
RUN yes | sdkmanager --licenses

# Install Android SDK components
RUN sdkmanager "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Disable analytics
RUN flutter config --no-analytics

# Get Flutter dependencies
RUN flutter --version

# Set working directory
WORKDIR /app

# Prebuild to cache dependencies
RUN echo "FROM scratch" > Dockerfile.prep && \
    mkdir -p lib/screens lib/services lib/models lib/config test && \
    echo "pubspec.yaml cache layer created"

# Default command
CMD ["/bin/bash"]
