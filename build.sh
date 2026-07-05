#!/bin/bash

# Exit on error
set -e

# Clone Flutter stable if not present
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "Flutter SDK already exists. Fetching updates..."
  cd flutter
  git fetch --depth 1
  git checkout stable
  cd ..
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Enable web support
echo "Enabling Flutter Web support..."
flutter config --enable-web

# Verify installation
flutter doctor

# Build web release
echo "Building Flutter Web for release..."
flutter build web --release
