#!/usr/bin/env bash

# Run this via make e2e-tests

# Exit on undefined variables and pipe failures
set -uo pipefail

# Run the test
./reverse tests/input/4/input.txt tests/input/4/input.txt
