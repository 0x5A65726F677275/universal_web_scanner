#!/bin/bash
# Universal Configuration File Hunter
# Hunts for exposed configuration files containing sensitive data
# Usage: ./config_hunter.sh <target_domain>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <target_domain>${NC}"
    echo "Example: $0 account.t-mobile.com"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="./results/${TARGET}"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[+] Universal Configuration File Hunter for ${TARGET}${NC}"
echo -e "${YELLOW}[*] Target: ${TARGET}${NC}"
echo "=================================="

# Common configuration file paths
CONFIG_PATHS=(
    "/assets/env.js"
    "/config.js"
    "/app.config.js"
    "/settings.js"
    "/env.js"
    "/config/env.js"
    "/config/config.js"
    "/js/config.js"
    "/static/config.js"
    "/assets/config.js"
    "/.env"
    "/web.config"
    "/app.config"
    "/appsettings.json"
    "/config.json"
    "/settings.json"
    "/environment.js"
    "/constants.js"
    "/configuration.js"
)

# Sensitive keywords to search for
SENSITIVE_KEYWORDS=(
    "client_id"
    "client_secret"
    "api_key"
    "apiKey"
    "secret"
    "password"
    "oauth"
    "token"
    "access_token"
    "private_key"
    "okta"
    "auth0"
    "entra"
    "azure"
    "aws_access_key"
    "recaptcha"
    "payment"
)

echo -e "${YELLOW}[*] Starting configuration file scan...${NC}\n"

for path in "${CONFIG_PATHS[@]}"; do
    URL="https://${TARGET}${path}"
    echo -e "${YELLOW}[*] Testing: ${URL}${NC}"
    
    # Make request and save response
    RESPONSE=$(curl -s -o "${OUTPUT_DIR}${path//\//_}.txt" -w "%{http_code}" "${URL}")
    
    if [ "$RESPONSE" = "200" ]; then
        echo -e "${GREEN}[✓] FOUND (200): ${URL}${NC}"
        
        # Check for sensitive keywords
        echo -e "${YELLOW}    [*] Scanning for sensitive data...${NC}"
        for keyword in "${SENSITIVE_KEYWORDS[@]}"; do
            if grep -qi "$keyword" "${OUTPUT_DIR}${path//\//_}.txt"; then
                echo -e "${RED}    [!!!] SENSITIVE KEYWORD FOUND: ${keyword}${NC}"
                grep -i "$keyword" "${OUTPUT_DIR}${path//\//_}.txt" | head -n 3
            fi
        done
        echo ""
    elif [ "$RESPONSE" = "403" ]; then
        echo -e "${YELLOW}[!] FORBIDDEN (403): ${URL} - File may exist but is protected${NC}\n"
    elif [ "$RESPONSE" = "401" ]; then
        echo -e "${YELLOW}[!] UNAUTHORIZED (401): ${URL} - Authentication required${NC}\n"
    else
        echo -e "[x] Not found (${RESPONSE}): ${URL}\n"
        rm -f "${OUTPUT_DIR}${path//\//_}.txt"
    fi
done

# Summary
echo "=================================="
echo -e "${GREEN}[+] Scan completed!${NC}"
echo -e "${YELLOW}[*] Results saved to: ${OUTPUT_DIR}${NC}"
echo ""
echo "Review found files manually for:"
echo "  - OAuth2 credentials (client_id, client_secret)"
echo "  - API keys and tokens"
echo "  - Payment gateway credentials"
echo "  - Internal endpoints and URLs"
echo "  - Database connection strings"
echo ""
echo -e "${RED}[!] If sensitive data found, document for security report!${NC}"

