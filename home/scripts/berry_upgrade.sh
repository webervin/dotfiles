#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# set -x # uncomment to debug, beware of secrets!

yarn set version stable --yarn-path

yarn config set enableTelemetry false
yarn config unsafeHttpWhitelist metadata.google.internal # for gcp auth plugin

# automatic GCP auth using token from ADC:
yarn plugin import https://github.com/AndyClausen/yarn-plugin-gcp-auth/releases/latest/download/plugin-gcp-auth.js
# require correct nodejs version.
yarn plugin import https://raw.githubusercontent.com/devoto13/yarn-plugin-engines/main/bundles/%40yarnpkg/plugin-engines.js

yarn install