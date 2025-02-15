#!/bin/bash

test -n "$1" || {
    echo 1>&2 "The first argument to $0 must be the directory containing the"
    echo 1>&2 "console.log file with the output of qemu/uml/... \$1 was empty!"
    exit 1
}

TMPOUTPUT="$1/console.log"
test -r "$TMPOUTPUT" || {
    echo 1>&2 "The file:"
    echo 1>&2 "    $TMPOUTPUT"
    echo 1>&2 "does NOT exist. Either no output was generated by the emulator, or"
    echo 1>&2 "the directory supplied via \$1 is incorrect."
    echo 1>&2 "Maybe the emulator failed to run the test? Maybe the test did not run? ..."
    exit 2
}

# See SF-73 for background
if grep -E -q '^1..0' "$TMPOUTPUT" ; then
    # munge the test output to fix-up the number of test suites
    N_TESTS="$(grep -c "    # Subtest:" "$TMPOUTPUT")" || true
    sed -i -e "s/^1..0/1..$N_TESTS/" "$TMPOUTPUT" || true
fi

if [ "$N_TESTS" == "0" ] || ! python3 "{parser}" parse < "$TMPOUTPUT"; then
  if [ "$N_TESTS" == "0" ]; then
    echo 1>&2 "=======> NO TESTS WERE RUN! Something went wrong."
  else
    echo 1>&2 "=======> TESTS FAILED. Scroll up to see the error."
  fi
  exit 100
fi
