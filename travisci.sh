set -e
cd JSON
if [[ $(md5 -q stops.json | tr -d '\n' | sort | diff stops.json.md5 -) ]] 
then
    echo "ERROR: stops.json.md5 is incorrect"
    (exit -1)
fi
if [[ $(md5 -q departures.json | tr -d '\n' | sort | diff departures.json.md5 -) ]] 
then
    echo "ERROR: departures.json.md5 is incorrect"
    (exit -1)
fi
cd ..
xcodebuild -project "tpg offline.xcodeproj" -scheme "tpg offline" -destination "platform=iOS Simulator,name=iPhone 8" test | xcpretty -c