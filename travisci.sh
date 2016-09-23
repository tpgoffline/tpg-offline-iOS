#!/usr/bin/env bash

set -e

xcodebuild -project "iOS/tpg offline.xcodeproj" -scheme "tpg offline Travis CI" -destination "platform=iOS Simulator,name=iPhone 7" test | xcpretty -c
