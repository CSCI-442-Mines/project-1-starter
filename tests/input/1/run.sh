#!/usr/bin/env bash

# Run this via make e2e-tests

# Exit on undefined variables and pipe failures
set -uo pipefail

# Run the test
./reverse in.txt out.txt burger.txt
