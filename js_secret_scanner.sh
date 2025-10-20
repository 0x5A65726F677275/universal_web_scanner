#!/bin/bash
# Universal JavaScript Secret Scanner
# Scans JavaScript files for exposed credentials and sensitive data
# Usage: ./js_secret_scanner.sh <target_domain>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <target_domain>${NC}"
    echo "Example: $0 devedge.t-mobile.com"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="./results/${TARGET}/js_scan"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[+] Universal JavaScript Secret Scanner for ${TARGET}${NC}"
echo -e "${YELLOW}[*] Target: ${TARGET}${NC}"
echo "=================================="

# Step 1: Download main page and extract JS files
echo -e "${YELLOW}[*] Step 1: Extracting JavaScript files...${NC}"
curl -s "https://${TARGET}" > "${OUTPUT_DIR}/index.html"

# Extract all JS file URLs
grep -oE '(src|href)="[^"]*\.js[^"]*"' "${OUTPUT_DIR}/index.html" | \
    sed 's/src="\|href="\|"//g' | \
    sort -u > "${OUTPUT_DIR}/js_files.txt"

# Also check for inline JS with potential secrets
echo -e "${YELLOW}[*] Checking for inline JavaScript...${NC}"
grep -oP '<script[^>]*>.*?</script>' "${OUTPUT_DIR}/index.html" > "${OUTPUT_DIR}/inline_js.txt" 2>/dev/null

JS_COUNT=$(wc -l < "${OUTPUT_DIR}/js_files.txt")
echo -e "${GREEN}[✓] Found ${JS_COUNT} JavaScript files${NC}\n"

# Step 2: Download each JS file
echo -e "${YELLOW}[*] Step 2: Downloading JavaScript files...${NC}"
COUNTER=1
while IFS= read -r js_url; do
    # Handle relative URLs
    if [[ $js_url == //* ]]; then
        js_url="https:${js_url}"
    elif [[ $js_url == /* ]]; then
        js_url="https://${TARGET}${js_url}"
    elif [[ ! $js_url == http* ]]; then
        js_url="https://${TARGET}/${js_url}"
    fi
    
    echo -e "${BLUE}[${COUNTER}/${JS_COUNT}] Downloading: ${js_url}${NC}"
    filename=$(echo "$js_url" | sed 's|https\?://||g' | sed 's|/|_|g')
    curl -s "$js_url" > "${OUTPUT_DIR}/${filename}" 2>/dev/null
    ((COUNTER++))
done < "${OUTPUT_DIR}/js_files.txt"

# Step 3: Search for sensitive patterns
echo -e "\n${YELLOW}[*] Step 3: Scanning for sensitive data patterns...${NC}\n"

# Regex patterns for secrets
declare -A PATTERNS=(
    ["OAuth Client ID"]="client_?id['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
    ["OAuth Secret"]="client_?secret['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
    ["API Key"]="api_?key['\"]?\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
    ["Bearer Token"]="Bearer\s+[a-zA-Z0-9_\-\.]{20,}"
    ["JWT Token"]="eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
    ["AWS Access Key"]="AKIA[0-9A-Z]{16}"
    ["Private Key"]="-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
    ["Generic Secret"]="secret['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    ["Password"]="password['\"]?\s*[:=]\s*['\"][^'\"]{6,}['\"]"
    ["Okta Domain"]="https://[a-zA-Z0-9-]+\.okta\.com"
    ["Auth0 Domain"]="https://[a-zA-Z0-9-]+\.(auth0|us\.auth0)\.com"
    ["Payment API"]="payment.*api.*['\"][^'\"]+['\"]"
    ["Database URL"]="(mongodb|mysql|postgres|redis)://[^\s'\"<>]+"
    ["reCAPTCHA Key"]="6L[a-zA-Z0-9_-]{38}"
)

FINDINGS_FILE="${OUTPUT_DIR}/FINDINGS.txt"
echo "JavaScript Secret Scan Results for ${TARGET}" > "$FINDINGS_FILE"
echo "Scan Date: $(date)" >> "$FINDINGS_FILE"
echo "========================================" >> "$FINDINGS_FILE"
echo "" >> "$FINDINGS_FILE"

TOTAL_FINDINGS=0

for pattern_name in "${!PATTERNS[@]}"; do
    pattern="${PATTERNS[$pattern_name]}"
    echo -e "${YELLOW}[*] Searching for: ${pattern_name}${NC}"
    
    # Search in downloaded JS files
    results=$(grep -rEio "$pattern" "${OUTPUT_DIR}"/*.js 2>/dev/null)
    
    if [ ! -z "$results" ]; then
        echo -e "${RED}[!!!] FOUND: ${pattern_name}${NC}"
        echo "$results" | while read -r line; do
            echo "  $line"
            TOTAL_FINDINGS=$((TOTAL_FINDINGS + 1))
        done
        
        # Save to findings file
        echo "[${pattern_name}]" >> "$FINDINGS_FILE"
        echo "$results" >> "$FINDINGS_FILE"
        echo "" >> "$FINDINGS_FILE"
        echo ""
    fi
done

# Step 4: Additional checks
echo -e "${YELLOW}[*] Step 4: Additional security checks...${NC}"

# Check for API endpoints
echo -e "${BLUE}[*] Searching for API endpoints...${NC}"
grep -rEoh "https?://[a-zA-Z0-9.-]+/api/[a-zA-Z0-9/_-]+" "${OUTPUT_DIR}"/*.js 2>/dev/null | \
    sort -u > "${OUTPUT_DIR}/api_endpoints.txt"
API_COUNT=$(wc -l < "${OUTPUT_DIR}/api_endpoints.txt" 2>/dev/null || echo 0)
echo -e "${GREEN}[✓] Found ${API_COUNT} unique API endpoints${NC}"

# Check for internal URLs
echo -e "${BLUE}[*] Searching for internal URLs...${NC}"
grep -rEoh "https?://[a-zA-Z0-9.-]+(internal|corp|admin|dev|stage|staging)[a-zA-Z0-9.-]*" \
    "${OUTPUT_DIR}"/*.js 2>/dev/null | sort -u > "${OUTPUT_DIR}/internal_urls.txt"
INTERNAL_COUNT=$(wc -l < "${OUTPUT_DIR}/internal_urls.txt" 2>/dev/null || echo 0)
echo -e "${GREEN}[✓] Found ${INTERNAL_COUNT} internal URLs${NC}"

# Check for AWS S3 buckets
echo -e "${BLUE}[*] Searching for S3 buckets...${NC}"
grep -rEoh "[a-zA-Z0-9.-]+\.s3\.amazonaws\.com|s3://[a-zA-Z0-9.-]+" \
    "${OUTPUT_DIR}"/*.js 2>/dev/null | sort -u > "${OUTPUT_DIR}/s3_buckets.txt"
S3_COUNT=$(wc -l < "${OUTPUT_DIR}/s3_buckets.txt" 2>/dev/null || echo 0)
echo -e "${GREEN}[✓] Found ${S3_COUNT} S3 bucket references${NC}"

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}[+] Scan Completed!${NC}"
echo "=========================================="
echo -e "Total Sensitive Findings: ${RED}${TOTAL_FINDINGS}${NC}"
echo -e "API Endpoints Found: ${YELLOW}${API_COUNT}${NC}"
echo -e "Internal URLs Found: ${YELLOW}${INTERNAL_COUNT}${NC}"
echo -e "S3 Buckets Found: ${YELLOW}${S3_COUNT}${NC}"
echo ""
echo -e "${YELLOW}Results saved to: ${OUTPUT_DIR}${NC}"
echo "  - Main findings: ${OUTPUT_DIR}/FINDINGS.txt"
echo "  - API endpoints: ${OUTPUT_DIR}/api_endpoints.txt"
echo "  - Internal URLs: ${OUTPUT_DIR}/internal_urls.txt"
echo "  - S3 buckets: ${OUTPUT_DIR}/s3_buckets.txt"
echo ""

if [ $TOTAL_FINDINGS -gt 0 ]; then
    echo -e "${RED}[!!!] SENSITIVE DATA FOUND - POTENTIAL CRITICAL VULNERABILITY!${NC}"
    echo -e "${RED}[!!!] Review ${OUTPUT_DIR}/FINDINGS.txt immediately${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Verify findings are legitimate secrets"
    echo "  2. Document with screenshots"
    echo "  3. Prepare detailed security report"
    echo "  4. Follow responsible disclosure practices"
else
    echo -e "${GREEN}[✓] No obvious secrets found in JavaScript files${NC}"
fi

