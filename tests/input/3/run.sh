#!/usr/bin/env bash

# Run this via make e2e-tests

# Exit on undefined variables and pipe failures
set -uo pipefail

# Run the test
./reverse /no/such/file.txt tests/output/3/output.txt
