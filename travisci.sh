#!/usr/bin/env bash

set -e

curl -OlL "https://github.com/Carthage/Carthage/releases/download/0.18.1/Carthage.pkg"
sudo installer -pkg "Carthage.pkg" -target /
rm "Carthage.pkg"

cd iOS

carthage update --platform "iOS"
carthage update --platform "watchOS"

xcodebuild -project "tpg offline.xcodeproj" -scheme "tpg offline Travis CI" -destination "platform=iOS Simulator,name=iPhone 7" test | xcpretty -c
