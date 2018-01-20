set -e
cd JSON
if [[ $(md5 -q stops.json | tr -d '\n' | sort | diff stops.json.md5 -) ]] 
then
    echo "✘ stops.json.md5 is incorrect"
    (exit -1)
else
    echo "✔︎ stops.json.md5 is correct"
fi
if [[ $(md5 -q departures.json | tr -d '\n' | sort | diff departures.json.md5 -) ]] 
then
    echo "✘ departures.json.md5 is incorrect"
    (exit -1)
else
    echo "✔︎ departures.json.md5 is correct"
fi
