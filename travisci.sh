#!/usr/bin/env bash

set -e

SWIFTLINT_PKG_PATH="/tmp/SwiftLint.pkg"
SWIFTLINT_PKG_URL="https://github.com/realm/SwiftLint/releases/download/0.9.1/SwiftLint.pkg"

wget --output-document=$SWIFTLINT_PKG_PATH $SWIFTLINT_PKG_URL

if [ -f $SWIFTLINT_PKG_PATH ]; then
  echo "SwiftLint package exists! Installing it..."
  sudo installer -pkg $SWIFTLINT_PKG_PATH -target /
else
  echo "SwiftLint package doesn't exist. Compiling from source..." &&
  git clone https://github.com/realm/SwiftLint.git /tmp/SwiftLint &&
  cd /tmp/SwiftLint &&
  git submodule update --init --recursive &&
  sudo make install
fi

curl -OlL "https://github.com/Carthage/Carthage/releases/download/0.18.1/Carthage.pkg"
sudo installer -pkg "Carthage.pkg" -target /
rm "Carthage.pkg"

cd iOS

carthage update --platform "iOS"
carthage update --platform "watchOS"

swiftlint

xcodebuild -project "tpg offline.xcodeproj" -scheme "tpg offline Travis CI" -destination "platform=iOS Simulator,name=iPhone 7" test | xcpretty -c
