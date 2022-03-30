#!/bin/bash

set -e

echo "Reading usernames"
IFS=" " read -r -a INPUT <<< "$(apify actor:get-input | jq -r '.usernames | join(" ")')"

echo "Usernames to check: ${INPUT[*]}"
python3 ./sherlock/sherlock.py --csv --timeout=3 "${INPUT[@]}"

for val in "${INPUT[@]}"
do
    < "${val}.csv" \
    python -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' \
    | apify actor:push-data
done
