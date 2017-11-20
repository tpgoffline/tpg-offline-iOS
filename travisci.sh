set -e
xcodebuild -project "tpg offline.xcodeproj" -scheme "tpg offline" -destination "platform=iOS Simulator,name=iPhone 8" test | xcpretty -c
