#!/bin/bash
LOG_DIR="logs"

PASSED=0
FAILED=0
SKIPPED=0
TESTS=0

PASSED_TESTS=()
FAILED_TESTS=()
SKIPPED_TESTS=()

MODULES=(
    "alu"
    # "control_unit"
    #"cpu"
    "memory"
    #"periphs",
    "reg_file"
    "top")

for MODULE in "${MODULES[@]}"; do
    echo "[ RUNNING $MODULE TEST BENCH... ]" 
    make run-tb PROJ=$MODULE LOG_FILE=$MODULE
    if grep -q 'TEST PASSED' "$LOG_DIR/$MODULE.txt"; then 
        PASSED_TESTS+=("$MODULE")
        ((PASSED++))
    elif grep -q 'TEST FAILED' "$LOG_DIR/$MODULE.txt"; then 
        FAILED_TESTS+=("$MODULE")
        ((FAILED++))
    else
        SKIPPED_TESTS+=("$MODULE")
        ((SKIPPED++))
    fi
    ((TESTS++))
done

echo "[ ========================== ]"
echo "[   REGRESSION TEST REPORT   ]"
echo "[ ========================== ]"
echo "[ FAILED =================== ]"
for FAILED_TEST in "${FAILED_TESTS[@]}"; do 
    echo "  - $FAILED_TEST "
done
echo "[ SKIPPED ================== ]"
for SKIPPED_TEST in "${SKIPPED_TESTS[@]}"; do 
    echo "  - $SKIPPED_TEST "
done
echo "[ PASSED =================== ]"
for PASSED_TEST in "${PASSED_TESTS[@]}"; do 
    echo "  - $PASSED_TEST "
done
echo "[ ========================== ]"
echo "  FAILED:  $FAILED/$TESTS"
echo "  SKIPPED: $SKIPPED/$TESTS"
echo "  PASSED:  $PASSED/$TESTS"
echo "[ ========================== ]"