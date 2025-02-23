#!/usr/bin/env bash

# End to end (e2e) tests
# Run this via make e2e-tests

################################################################################
#                                   Settings                                   #
################################################################################

# Test cases to run (One or more of: "1" "2" "3" "4" "5")
CASES=("1" "2" "3" "4" "5")

################################################################################
#                                  Internals                                   #
################################################################################

# Exit on undefined variables and pipe failures
set -uo pipefail

# ANSI color codes
GRAY="\033[0;37m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Logging prefixes
DEBUG="${GRAY}[DEBUG]${RESET}"
SUCCESS="${GREEN}[SUCCESS]${RESET}"
WARNING="${YELLOW}[WARNING]${RESET}"
ERROR="${RED}[ERROR]${RESET}"

# Get the directory of the project root
ROOT_DIR="$(dirname "$(dirname "$(readlink -f "${0}")")")"

# Get the path to the binary
BINARY="${ROOT_DIR}/reverse"

# Run a test
# Parameters:
# - $1: The case
# Globals:
# - BINARY: The path to the binary
# - ROOT_DIR: The directory of the project root
function run_test {
	# Generate the input and output file names
  local INPUT_BASE_NAME="${ROOT_DIR}/tests/input/${1}"
	local INPUT_DESCRIPTION_NAME="${INPUT_BASE_NAME}/description.txt"
  local INPUT_RUN_NAME="${INPUT_BASE_NAME}/run.sh"

  local OUTPUT_BASE_NAME="${ROOT_DIR}/tests/output/${1}"

	local OUTPUT_EXEPECTED_EXIT_NAME="${OUTPUT_BASE_NAME}/exit.expected"
	local OUTPUT_EXEPECTED_OUTPUT_NAME="${OUTPUT_BASE_NAME}/output.expected"
  local OUTPUT_EXEPECTED_STDERR_NAME="${OUTPUT_BASE_NAME}/stderr.expected"
  local OUTPUT_EXEPECTED_STDOUT_NAME="${OUTPUT_BASE_NAME}/stdout.expected"

  local OUTPUT_ACTUAL_EXIT_NAME="${OUTPUT_BASE_NAME}/exit.actual"
  local OUTPUT_ACTUAL_OUTPUT_NAME="${OUTPUT_BASE_NAME}/output.actual"
  local OUTPUT_ACTUAL_STDERR_NAME="${OUTPUT_BASE_NAME}/stderr.actual"
  local OUTPUT_ACTUAL_STDOUT_NAME="${OUTPUT_BASE_NAME}/stdout.actual"


  local OUTPUT_EXIT_DIFF_NAME="${OUTPUT_BASE_NAME}/exit.diff"
  local OUTPUT_OUTPUT_DIFF_NAME="${OUTPUT_BASE_NAME}/output.diff"
  local OUTPUT_STDERR_DIFF_NAME="${OUTPUT_BASE_NAME}/stderr.diff"
  local OUTPUT_STDOUT_DIFF_NAME="${OUTPUT_BASE_NAME}/stdout.diff"

  # Get the description
  local DESCRIPTION=$(cat "${INPUT_DESCRIPTION_NAME}")

	# Delete old output files
	rm -f ${OUTPUT_BASE_NAME}/*.{actual,diff}

	# Run the command
	echo -e "${DEBUG} Running: ${INPUT_RUN_NAME} in ${ROOT_DIR}"
	(cd "${ROOT_DIR}"; "${INPUT_RUN_NAME}" > "${OUTPUT_ACTUAL_STDOUT_NAME}" 2> "${OUTPUT_ACTUAL_STDERR_NAME}")
  local EXIT_CODE="${?}"
  echo "${EXIT_CODE}" > "${OUTPUT_ACTUAL_EXIT_NAME}"

  # Compare the exit code
  local EXIT_DIFF=$(diff --label "Expected exit code" --label "Actual exit code" --unified "${OUTPUT_EXEPECTED_EXIT_NAME}" "${OUTPUT_ACTUAL_EXIT_NAME}")

  if [ "${EXIT_DIFF}" != "" ]; then
    echo "${EXIT_DIFF}" > "${OUTPUT_EXIT_DIFF_NAME}"
    echo -e "${ERROR} Test failed! (Case: ${1} - ${DESCRIPTION}, cause: bad exit code, diff: ${OUTPUT_EXIT_DIFF_NAME})"
    return 1
  fi

  # Compare the output
  if [ -f "${OUTPUT_EXEPECTED_OUTPUT_NAME}" ]; then
    local OUTPUT_DIFF=$(diff --label "Expected output" --label "Actual output" --unified "${OUTPUT_EXEPECTED_OUTPUT_NAME}" "${OUTPUT_ACTUAL_OUTPUT_NAME}")

    if [ "${OUTPUT_DIFF}" != "" ]; then
      echo "${OUTPUT_DIFF}" > "${OUTPUT_OUTPUT_DIFF_NAME}"
      echo -e "${ERROR} Test failed! (Case: ${1} - ${DESCRIPTION}, cause: bad output, diff: ${OUTPUT_OUTPUT_DIFF_NAME})"
      return 1
    fi
  fi

  # Compare the stderr
  local STDERR_DIFF=$(diff --label "Expected stderr" --label "Actual stderr" --unified "${OUTPUT_EXEPECTED_STDERR_NAME}" "${OUTPUT_ACTUAL_STDERR_NAME}")

  if [ "${STDERR_DIFF}" != "" ]; then
    echo "${STDERR_DIFF}" > "${OUTPUT_STDERR_DIFF_NAME}"
    echo -e "${ERROR} Test failed! (Case: ${1} - ${DESCRIPTION}, cause: bad stderr, diff: ${OUTPUT_STDERR_DIFF_NAME})"
    return 1
  fi

  # Compare the stdout
  local STDOUT_DIFF=$(diff --label "Expected stdou" --label "Actual stdout" --unified "${OUTPUT_ACTUAL_STDOUT_NAME}" "${OUTPUT_EXEPECTED_STDOUT_NAME}")

  if [ "${STDOUT_DIFF}" != "" ]; then
    echo "${STDOUT_DIFF}" > "${OUTPUT_STDOUT_DIFF_NAME}"
    echo -e "${ERROR} Test failed! (Case: ${1} - ${DESCRIPTION}, cause: bad stdout, diff: ${OUTPUT_STDOUT_DIFF_NAME})"
    return 1
  fi

  echo -e "${SUCCESS} Test passed! (Case: ${1} - ${DESCRIPTION})"

	return 0
}

# Check if invoked by Make
if [ "${MAKELEVEL:-0}" -ne 1 ]; then
  echo -e "${ERROR} This script should be run via make e2e-tests!"
  exit 1
fi

# Run end to end tests
ALL_TESTS_PASSED=true
for CASE in "${CASES[@]}"; do
    run_test "${CASE}"

    if [ "${?}" -ne 0 ]; then
        ALL_TESTS_PASSED=false
    fi
done

# Print the result
if [ "${ALL_TESTS_PASSED}" == false ]; then
	echo -e "${ERROR} Some tests failed!"
	exit 1
else
	echo -e "${SUCCESS} All configured end to end tests passed!"
	exit 0
fi
