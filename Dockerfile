# We need the non-slim image for the apify-cli installation
FROM nikolaik/python-nodejs:python3.7-nodejs16 as build

# Install the Apify CLI globally, to /usr/lib/node_modules
RUN npm install -g apify-cli@0.7.1-beta.4

# To save space, we can use the slim image for running
FROM nikolaik/python-nodejs:python3.7-nodejs16-slim as run
WORKDIR /opt/sherlock

# Copy over the global node_modules from the build stage
COPY --from=build /usr/lib/node_modules /usr/lib/node_modules

# Add symlink to be able to run `apify` globally
RUN ln -s /usr/lib/node_modules/apify-cli/src/bin/run /usr/bin/apify

# Install jq and miller for JSON and CSV processing
RUN apt-get update \
 && apt-get install -y \
        jq \
        miller \
 && rm -rf /var/lib/apt/lists/*

# Install the Python requirements
COPY requirements.txt .
RUN pip3 install --no-cache -r requirements.txt

# Copy over the rest of the code
COPY . .

# Run the actor code by default
CMD ./.actor/start.sh
