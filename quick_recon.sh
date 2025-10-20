#!/bin/bash
# Universal Quick Reconnaissance
# Fast initial recon of any target domain
# Usage: ./quick_recon.sh <target_domain>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <target_domain>${NC}"
    echo "Example: $0 account.t-mobile.com"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="./results/${TARGET}/recon"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║   Universal Quick Reconnaissance         ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Target: ${TARGET}${NC}"
echo -e "${YELLOW}Date: $(date)${NC}"
echo "==========================================="
echo ""

# DNS Information
echo -e "${PURPLE}[1/8] DNS Information${NC}"
echo "-------------------------------------------"
dig +short $TARGET | tee "${OUTPUT_DIR}/dns.txt"
echo ""

# IP Information
echo -e "${PURPLE}[2/8] IP Address Resolution${NC}"
echo "-------------------------------------------"
IP=$(dig +short $TARGET | head -n 1)
echo -e "IPv4: ${GREEN}${IP}${NC}"
dig +short AAAA $TARGET | head -n 1
echo ""

# Technology Detection
echo -e "${PURPLE}[3/8] Technology Stack Detection${NC}"
echo "-------------------------------------------"
if command -v whatweb &> /dev/null; then
    whatweb -v "https://${TARGET}" | tee "${OUTPUT_DIR}/whatweb.txt"
else
    echo -e "${RED}whatweb not installed${NC}"
fi
echo ""

# WAF Detection
echo -e "${PURPLE}[4/8] WAF/CDN Detection${NC}"
echo "-------------------------------------------"
if command -v wafw00f &> /dev/null; then
    wafw00f "https://${TARGET}" | tee "${OUTPUT_DIR}/waf.txt"
else
    echo -e "${RED}wafw00f not installed${NC}"
fi
echo ""

# HTTP Headers
echo -e "${PURPLE}[5/8] HTTP Security Headers${NC}"
echo "-------------------------------------------"
curl -s -D - "https://${TARGET}" | grep -E "^(HTTP|Server:|X-|Content-Security|Strict-Transport)" | \
    tee "${OUTPUT_DIR}/headers.txt"
echo ""

# SSL/TLS Information
echo -e "${PURPLE}[6/8] SSL/TLS Certificate${NC}"
echo "-------------------------------------------"
echo | openssl s_client -servername $TARGET -connect $TARGET:443 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates 2>/dev/null | \
    tee "${OUTPUT_DIR}/ssl.txt"
echo ""

# Common Endpoints Check
echo -e "${PURPLE}[7/8] Common Endpoints Check${NC}"
echo "-------------------------------------------"
declare -A ENDPOINTS=(
    ["/robots.txt"]="Robots file"
    ["/sitemap.xml"]="Sitemap"
    ["/.well-known/security.txt"]="Security policy"
    ["/api"]="API endpoint"
    ["/graphql"]="GraphQL endpoint"
    ["/swagger"]="Swagger docs"
    ["/.git/config"]="Git exposure"
    ["/.env"]="Environment file"
    ["/config.json"]="Config file"
)

for endpoint in "${!ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}${endpoint}")
    if [ "$STATUS" = "200" ]; then
        echo -e "${GREEN}[✓] ${STATUS} - ${endpoint} (${ENDPOINTS[$endpoint]})${NC}"
    elif [ "$STATUS" = "403" ] || [ "$STATUS" = "401" ]; then
        echo -e "${YELLOW}[!] ${STATUS} - ${endpoint} (${ENDPOINTS[$endpoint]})${NC}"
    fi
done
echo ""

# Port Scan (Quick)
echo -e "${PURPLE}[8/8] Quick Port Scan${NC}"
echo "-------------------------------------------"
if command -v nmap &> /dev/null; then
    echo "Scanning common web ports..."
    nmap -Pn -p 80,443,8080,8443 $TARGET | tee "${OUTPUT_DIR}/ports.txt"
else
    echo -e "${RED}nmap not installed${NC}"
fi
echo ""

# robots.txt Analysis
if curl -s "https://${TARGET}/robots.txt" | grep -q "Disallow"; then
    echo -e "${PURPLE}[*] Interesting paths from robots.txt:${NC}"
    echo "-------------------------------------------"
    curl -s "https://${TARGET}/robots.txt" | grep "Disallow" | head -n 10 | \
        tee "${OUTPUT_DIR}/robots_disallow.txt"
    echo ""
fi

# Summary
echo ""
echo "==========================================="
echo -e "${GREEN}[+] Quick Reconnaissance Completed!${NC}"
echo "==========================================="
echo ""
echo -e "${YELLOW}Results saved to: ${OUTPUT_DIR}${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Run config_hunter.sh to find exposed configuration files"
echo "  2. Run js_secret_scanner.sh to scan JavaScript for secrets"
echo "  3. Run api_discovery.sh for API endpoint enumeration"
echo "  4. Manual testing of found endpoints"
echo ""
echo -e "${YELLOW}Priority Checks:${NC}"
echo "  ⚠️  Look for /assets/env.js (similar to LER portal)"
echo "  ⚠️  Check for OAuth credentials in JS files"
echo "  ⚠️  Test authentication/authorization on APIs"
echo "  ⚠️  Verify security header implementation"

