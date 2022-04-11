#!/bin/bash

set -e

# Input is a JSON with an array of usernames under the `usernames` property
echo "Reading usernames from input..."
usernames=$(apify actor:get-input | jq -r '.usernames | join(" ")')
echo "Usernames to check: ${usernames}"

# Run Sherlock to check for the usernames' availability, and save results to the `results` folder
python3 ./sherlock/sherlock.py --csv --folderoutput results --timeout=3 --print-found ${usernames}

# use Miller to join the CSVs and transform them to JSON,
# and then push that JSON the actor output
echo "Pushing results to dataset..."
mlr --icsv --ojson --jlistwrap cat results/*.csv | apify actor:push-data

echo "Done."
