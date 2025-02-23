#!/usr/bin/env bash

# Run this via make e2e-tests

# Exit on undefined variables and pipe failures
set -uo pipefail

# Run the test
./reverse tests/input/5/input.txt tests/output/5/output.actual
