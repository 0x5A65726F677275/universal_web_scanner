#!/bin/bash
# Universal API Discovery Tool
# Discovers API endpoints and tests security for any domain
# Usage: ./api_discovery.sh <target_domain>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <target_domain>${NC}"
    echo "Example: $0 api.t-mobile.com"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="./results/${TARGET}/api_discovery"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[+] Universal API Discovery Tool for ${TARGET}${NC}"
echo -e "${YELLOW}[*] Target: ${TARGET}${NC}"
echo "=================================="

# Common API paths
API_PATHS=(
    "/api"
    "/api/v1"
    "/api/v2"
    "/api/v3"
    "/v1"
    "/v2"
    "/v3"
    "/rest"
    "/rest/api"
    "/graphql"
    "/graph"
    "/swagger"
    "/swagger.json"
    "/swagger/v1/swagger.json"
    "/api-docs"
    "/api/docs"
    "/docs"
    "/openapi.json"
    "/api/swagger.json"
    "/api.json"
)

# Common API endpoints to test
API_ENDPOINTS=(
    "/api/users"
    "/api/user"
    "/api/profile"
    "/api/account"
    "/api/accounts"
    "/api/customers"
    "/api/auth"
    "/api/login"
    "/api/config"
    "/api/settings"
    "/api/admin"
    "/api/health"
    "/api/status"
    "/api/version"
)

echo -e "${YELLOW}[*] Phase 1: Discovering API base paths...${NC}\n"

for path in "${API_PATHS[@]}"; do
    URL="https://${TARGET}${path}"
    RESPONSE=$(curl -s -o "${OUTPUT_DIR}${path//\//_}.txt" -w "%{http_code}" "${URL}")
    
    if [ "$RESPONSE" = "200" ]; then
        echo -e "${GREEN}[✓] FOUND (200): ${URL}${NC}"
        # Check if it's JSON
        if grep -q "{" "${OUTPUT_DIR}${path//\//_}.txt" 2>/dev/null; then
            echo -e "${BLUE}    [*] Response appears to be JSON${NC}"
        fi
    elif [ "$RESPONSE" = "401" ]; then
        echo -e "${YELLOW}[!] AUTH REQUIRED (401): ${URL}${NC}"
    elif [ "$RESPONSE" = "403" ]; then
        echo -e "${YELLOW}[!] FORBIDDEN (403): ${URL}${NC}"
    elif [ "$RESPONSE" = "404" ]; then
        rm -f "${OUTPUT_DIR}${path//\//_}.txt"
    else
        echo "[x] ${RESPONSE}: ${URL}"
        rm -f "${OUTPUT_DIR}${path//\//_}.txt"
    fi
done

echo -e "\n${YELLOW}[*] Phase 2: Testing common API endpoints...${NC}\n"

for endpoint in "${API_ENDPOINTS[@]}"; do
    URL="https://${TARGET}${endpoint}"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}")
    
    if [ "$RESPONSE" != "404" ]; then
        echo -e "${GREEN}[✓] ${RESPONSE}: ${URL}${NC}"
    fi
done

# GraphQL specific checks
echo -e "\n${YELLOW}[*] Phase 3: GraphQL introspection check...${NC}\n"

GRAPHQL_URLS=(
    "https://${TARGET}/graphql"
    "https://${TARGET}/api/graphql"
    "https://${TARGET}/v1/graphql"
)

INTROSPECTION_QUERY='{"query":"{ __schema { types { name } } }"}'

for gql_url in "${GRAPHQL_URLS[@]}"; do
    echo -e "${BLUE}[*] Testing: ${gql_url}${NC}"
    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "$INTROSPECTION_QUERY" \
        -o "${OUTPUT_DIR}/graphql_introspection.json" \
        -w "%{http_code}" \
        "${gql_url}")
    
    if [ "$RESPONSE" = "200" ]; then
        if grep -q "__schema" "${OUTPUT_DIR}/graphql_introspection.json" 2>/dev/null; then
            echo -e "${RED}[!!!] GraphQL introspection ENABLED: ${gql_url}${NC}"
            echo -e "${RED}     This could be a security issue!${NC}"
        else
            echo -e "${GREEN}[✓] GraphQL endpoint found but introspection disabled${NC}"
        fi
    fi
done

# Swagger/OpenAPI documentation check
echo -e "\n${YELLOW}[*] Phase 4: API documentation exposure...${NC}\n"

SWAGGER_PATHS=(
    "/swagger-ui.html"
    "/swagger-ui/"
    "/swagger/index.html"
    "/api/swagger-ui.html"
    "/swagger-ui/index.html"
    "/api-docs"
)

for swagger in "${SWAGGER_PATHS[@]}"; do
    URL="https://${TARGET}${swagger}"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}")
    
    if [ "$RESPONSE" = "200" ]; then
        echo -e "${YELLOW}[!] Swagger UI accessible: ${URL}${NC}"
        echo -e "${BLUE}    This may expose API structure and endpoints${NC}"
    fi
done

# Test for common API security issues
echo -e "\n${YELLOW}[*] Phase 5: Basic security checks...${NC}\n"

# Check for CORS misconfiguration
echo -e "${BLUE}[*] Testing CORS configuration...${NC}"
curl -s -H "Origin: https://evil.com" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: X-Requested-With" \
    -X OPTIONS \
    -D "${OUTPUT_DIR}/cors_test.txt" \
    "https://${TARGET}/api" > /dev/null 2>&1

if grep -q "Access-Control-Allow-Origin: \*" "${OUTPUT_DIR}/cors_test.txt" 2>/dev/null; then
    echo -e "${RED}[!!!] CORS misconfiguration detected: Access-Control-Allow-Origin: *${NC}"
elif grep -q "Access-Control-Allow-Origin: https://evil.com" "${OUTPUT_DIR}/cors_test.txt" 2>/dev/null; then
    echo -e "${RED}[!!!] CORS misconfiguration: Arbitrary origins allowed${NC}"
else
    echo -e "${GREEN}[✓] CORS appears to be properly configured${NC}"
fi

# Check for security headers
echo -e "\n${BLUE}[*] Checking security headers...${NC}"
curl -s -D "${OUTPUT_DIR}/headers.txt" "https://${TARGET}" > /dev/null

declare -A SECURITY_HEADERS=(
    ["X-Frame-Options"]="Protects against clickjacking"
    ["X-Content-Type-Options"]="Prevents MIME sniffing"
    ["Content-Security-Policy"]="Mitigates XSS attacks"
    ["Strict-Transport-Security"]="Enforces HTTPS"
    ["X-XSS-Protection"]="Legacy XSS protection"
)

echo ""
for header in "${!SECURITY_HEADERS[@]}"; do
    if grep -qi "^${header}:" "${OUTPUT_DIR}/headers.txt"; then
        echo -e "${GREEN}[✓] ${header}: Present${NC}"
    else
        echo -e "${YELLOW}[!] ${header}: Missing - ${SECURITY_HEADERS[$header]}${NC}"
    fi
done

# API version enumeration
echo -e "\n${YELLOW}[*] Phase 6: API version enumeration...${NC}\n"

for i in {1..5}; do
    URL="https://${TARGET}/api/v${i}"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}")
    if [ "$RESPONSE" != "404" ]; then
        echo -e "${GREEN}[✓] API v${i} found (${RESPONSE}): ${URL}${NC}"
    fi
done

# Rate limiting check
echo -e "\n${YELLOW}[*] Phase 7: Rate limiting check...${NC}\n"
echo -e "${BLUE}[*] Sending 10 rapid requests to check rate limiting...${NC}"

RATE_LIMIT_DETECTED=false
for i in {1..10}; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}/api")
    if [ "$RESPONSE" = "429" ]; then
        echo -e "${GREEN}[✓] Rate limiting detected (429 Too Many Requests)${NC}"
        RATE_LIMIT_DETECTED=true
        break
    fi
done

if [ "$RATE_LIMIT_DETECTED" = false ]; then
    echo -e "${YELLOW}[!] No rate limiting detected - Potential security issue${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}[+] API Discovery Completed!${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}Results saved to: ${OUTPUT_DIR}${NC}"
echo ""
echo "Review the following:"
echo "  1. Found API endpoints and their response codes"
echo "  2. GraphQL introspection status"
echo "  3. API documentation exposure"
echo "  4. CORS configuration"
echo "  5. Missing security headers"
echo "  6. Rate limiting implementation"
echo ""
echo "Next steps:"
echo "  - Test authentication/authorization on found endpoints"
echo "  - Check for IDOR vulnerabilities"
echo "  - Test for excessive data exposure"
echo "  - Verify proper input validation"
echo "  - Check for mass assignment issues"

