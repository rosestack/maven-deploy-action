#!/bin/bash

# Local test script for maven-release-action
# This script validates the test project works correctly

set -e

echo "========================================"
echo "Maven Release Action - Local Test"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to test project directory
cd "$(dirname "$0")/test-project"

echo "📁 Working directory: $(pwd)"
echo ""

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}❌ Maven is not installed. Please install Maven first.${NC}"
    exit 1
fi

echo "✅ Maven is installed"
mvn --version
echo ""

# Function to run a test
run_test() {
    local test_name=$1
    local test_cmd=$2
    
    echo "========================================"
    echo "🧪 Test: $test_name"
    echo "========================================"
    echo "Command: $test_cmd"
    echo ""
    
    if eval "$test_cmd"; then
        echo ""
        echo -e "${GREEN}✅ $test_name: PASSED${NC}"
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}❌ $test_name: FAILED${NC}"
        echo ""
        return 1
    fi
}

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test 1: Clean
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Clean project" "mvn clean"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 2: Compile
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Compile source code" "mvn compile"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 3: Run tests
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Run unit tests" "mvn test"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 4: Verify with coverage
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Verify with coverage" "mvn verify"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 5: Package
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Package artifacts" "mvn package -DskipTests"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 6: Install
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Install to local repository" "mvn install -DskipTests"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 7: Generate site (optional - can be slow)
if [ "${SKIP_SITE:-false}" != "true" ]; then
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if run_test "Generate site documentation" "mvn site"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${YELLOW}⚠️  Site generation failed, but this is optional${NC}"
    fi
fi

# Display results
echo "========================================"
echo "📊 Test Results Summary"
echo "========================================"
echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
else
    echo "Failed:       $FAILED_TESTS"
fi
echo ""

# Check artifacts
echo "========================================"
echo "📦 Generated Artifacts"
echo "========================================"
echo ""

if [ -d target ]; then
    echo "JAR Files:"
    find target -maxdepth 1 -name "*.jar" -exec basename {} \; | while read file; do
        echo "  ✓ $file"
    done
    echo ""
    
    echo "Coverage Report:"
    if [ -f target/jacoco-results/index.html ]; then
        echo "  ✓ target/jacoco-results/index.html"
    else
        echo "  ✗ Coverage report not found"
    fi
    echo ""
    
    echo "Test Reports:"
    if [ -d target/surefire-reports ]; then
        TEST_COUNT=$(find target/surefire-reports -name "*.xml" | wc -l)
        echo "  ✓ $TEST_COUNT test report(s) in target/surefire-reports/"
    else
        echo "  ✗ Test reports not found"
    fi
    echo ""
    
    if [ "${SKIP_SITE:-false}" != "true" ]; then
        echo "Site Documentation:"
        if [ -d target/site ]; then
            echo "  ✓ target/site/index.html"
        else
            echo "  ✗ Site not found"
        fi
        echo ""
    fi
else
    echo -e "${RED}✗ Target directory not found${NC}"
    echo ""
fi

# Final status
echo "========================================"
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "  1. Open coverage report: open test-project/target/jacoco-results/index.html"
    if [ "${SKIP_SITE:-false}" != "true" ]; then
        echo "  2. Open site documentation: open test-project/target/site/index.html"
    fi
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo "========================================"
    echo ""
    exit 1
fi

