#!/bin/bash
# Universal Web Security Testing Suite
# Comprehensive security assessment for any domain
# Usage: ./master_test.sh <target_domain> [program_name]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <target_domain> [program_name]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 example.com"
    echo "  $0 api.example.com \"Example Bug Bounty\""
    echo "  $0 app.example.com HackerOne"
    echo ""
    echo "Parameters:"
    echo "  target_domain   - Domain to test (required)"
    echo "  program_name    - Bug bounty program name (optional)"
    exit 1
fi

TARGET=$1
PROGRAM_NAME=${2:-"Bug Bounty Program"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/results/${TARGET}"
REPORT_FILE="${OUTPUT_DIR}/MASTER_REPORT.txt"

mkdir -p "$OUTPUT_DIR"

# Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║    Universal Web Security Testing Suite          ║"
echo "║    Comprehensive Security Assessment              ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}Target: ${TARGET}${NC}"
echo -e "${YELLOW}Program: ${PROGRAM_NAME}${NC}"
echo -e "${YELLOW}Date: $(date)${NC}"
echo -e "${YELLOW}Output Directory: ${OUTPUT_DIR}${NC}"
echo "====================================================="
echo ""

# Initialize report
cat > "$REPORT_FILE" << EOF
═══════════════════════════════════════════════════════════
WEB SECURITY ASSESSMENT REPORT
═══════════════════════════════════════════════════════════

Target: ${TARGET}
Program: ${PROGRAM_NAME}
Assessment Date: $(date)
Tester: Automated Security Assessment
Assessment Type: Black-box Security Testing

═══════════════════════════════════════════════════════════
EXECUTIVE SUMMARY
═══════════════════════════════════════════════════════════

This report documents the security assessment of ${TARGET}.
Testing was conducted ethically and within authorized scope.

All testing followed responsible disclosure practices and
adhered to bug bounty program guidelines where applicable.

═══════════════════════════════════════════════════════════

EOF

echo -e "${GREEN}[✓] Report initialized: ${REPORT_FILE}${NC}\n"

# Phase 1: Quick Reconnaissance
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}PHASE 1: RECONNAISSANCE & INFORMATION GATHERING${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/quick_recon.sh" ]; then
    echo -e "${CYAN}[*] Running reconnaissance...${NC}"
    bash "${SCRIPT_DIR}/quick_recon.sh" "$TARGET"
    
    echo "" >> "$REPORT_FILE"
    echo "PHASE 1: RECONNAISSANCE" >> "$REPORT_FILE"
    echo "─────────────────────────────────────────────────────" >> "$REPORT_FILE"
    cat "${OUTPUT_DIR}/recon/"*.txt >> "$REPORT_FILE" 2>/dev/null
    echo -e "${GREEN}[✓] Phase 1 completed${NC}\n"
else
    echo -e "${RED}[x] quick_recon.sh not found${NC}\n"
fi

sleep 2

# Phase 2: Configuration File Hunting
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}PHASE 2: CONFIGURATION FILE EXPOSURE ANALYSIS${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}[!] Searching for exposed configuration files and credentials${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/config_hunter.sh" ]; then
    echo -e "${CYAN}[*] Hunting for exposed configuration files...${NC}"
    bash "${SCRIPT_DIR}/config_hunter.sh" "$TARGET"
    
    echo "" >> "$REPORT_FILE"
    echo "PHASE 2: CONFIGURATION FILE EXPOSURE CHECK" >> "$REPORT_FILE"
    echo "─────────────────────────────────────────────────────" >> "$REPORT_FILE"
    
    # Check if any sensitive data was found
    if ls ${OUTPUT_DIR}/*.txt 1> /dev/null 2>&1; then
        echo "[!] Configuration files found - Manual review required!" >> "$REPORT_FILE"
        ls ${OUTPUT_DIR}/*.txt >> "$REPORT_FILE"
    else
        echo "[✓] No exposed configuration files found" >> "$REPORT_FILE"
    fi
    
    echo -e "${GREEN}[✓] Phase 2 completed${NC}\n"
else
    echo -e "${RED}[x] config_hunter.sh not found${NC}\n"
fi

sleep 2

# Phase 3: JavaScript Secret Scanning
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}PHASE 3: JAVASCRIPT SECRET & CREDENTIAL ANALYSIS${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/js_secret_scanner.sh" ]; then
    echo -e "${CYAN}[*] Scanning JavaScript files for exposed secrets...${NC}"
    bash "${SCRIPT_DIR}/js_secret_scanner.sh" "$TARGET"
    
    echo "" >> "$REPORT_FILE"
    echo "PHASE 3: JAVASCRIPT SECRET ANALYSIS" >> "$REPORT_FILE"
    echo "─────────────────────────────────────────────────────" >> "$REPORT_FILE"
    
    if [ -f "${OUTPUT_DIR}/js_scan/FINDINGS.txt" ]; then
        cat "${OUTPUT_DIR}/js_scan/FINDINGS.txt" >> "$REPORT_FILE"
    else
        echo "[✓] No obvious secrets found in JavaScript files" >> "$REPORT_FILE"
    fi
    
    echo -e "${GREEN}[✓] Phase 3 completed${NC}\n"
else
    echo -e "${RED}[x] js_secret_scanner.sh not found${NC}\n"
fi

sleep 2

# Phase 4: API Discovery
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}PHASE 4: API DISCOVERY & SECURITY TESTING${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/api_discovery.sh" ]; then
    echo -e "${CYAN}[*] Discovering and testing API endpoints...${NC}"
    bash "${SCRIPT_DIR}/api_discovery.sh" "$TARGET"
    
    echo "" >> "$REPORT_FILE"
    echo "PHASE 4: API SECURITY ASSESSMENT" >> "$REPORT_FILE"
    echo "─────────────────────────────────────────────────────" >> "$REPORT_FILE"
    
    if [ -f "${OUTPUT_DIR}/api_discovery/api_endpoints.txt" ]; then
        echo "Discovered API Endpoints:" >> "$REPORT_FILE"
        cat "${OUTPUT_DIR}/api_discovery/api_endpoints.txt" >> "$REPORT_FILE" 2>/dev/null
    fi
    
    echo -e "${GREEN}[✓] Phase 4 completed${NC}\n"
else
    echo -e "${RED}[x] api_discovery.sh not found${NC}\n"
fi

sleep 2

# Phase 5: Additional Security Checks
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}PHASE 5: ADDITIONAL SECURITY CHECKS${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}[*] Performing additional vulnerability checks...${NC}"

# Check for common vulnerabilities
echo "" >> "$REPORT_FILE"
echo "PHASE 5: ADDITIONAL SECURITY CHECKS" >> "$REPORT_FILE"
echo "─────────────────────────────────────────────────────" >> "$REPORT_FILE"

# Check for .git exposure
echo -e "${BLUE}  [*] Checking for .git exposure...${NC}"
GIT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}/.git/config")
if [ "$GIT_STATUS" = "200" ]; then
    echo -e "${RED}  [!!!] .git directory exposed!${NC}"
    echo "[!!!] CRITICAL: .git directory exposed at https://${TARGET}/.git/" >> "$REPORT_FILE"
else
    echo -e "${GREEN}  [✓] .git directory not exposed${NC}"
fi

# Check for backup files
echo -e "${BLUE}  [*] Checking for backup files...${NC}"
BACKUP_FILES=("index.php.bak" "web.config.bak" "config.php.old" ".env.backup" "backup.zip" "backup.tar.gz" "db_backup.sql")
for backup in "${BACKUP_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}/${backup}")
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  [!!!] Backup file found: ${backup}${NC}"
        echo "[!] Backup file accessible: https://${TARGET}/${backup}" >> "$REPORT_FILE"
    fi
done

# Check for common sensitive files
echo -e "${BLUE}  [*] Checking for sensitive files...${NC}"
SENSITIVE_FILES=(".env" "config.php" "database.yml" "credentials.json" "secrets.json" ".aws/credentials")
for file in "${SENSITIVE_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TARGET}/${file}")
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  [!!!] Sensitive file exposed: ${file}${NC}"
        echo "[!!!] CRITICAL: Sensitive file exposed at https://${TARGET}/${file}" >> "$REPORT_FILE"
    fi
done

# Check for AWS S3 bucket
echo -e "${BLUE}  [*] Checking for S3 bucket references...${NC}"
curl -s "https://${TARGET}" | grep -o '[a-zA-Z0-9.-]*\.s3\.amazonaws\.com' | sort -u > "${OUTPUT_DIR}/s3_buckets.txt" 2>/dev/null
if [ -s "${OUTPUT_DIR}/s3_buckets.txt" ]; then
    echo -e "${YELLOW}  [!] S3 buckets found - Check permissions${NC}"
    echo "" >> "$REPORT_FILE"
    echo "S3 Buckets Found (Check for public access):" >> "$REPORT_FILE"
    cat "${OUTPUT_DIR}/s3_buckets.txt" >> "$REPORT_FILE"
fi

# Check for Google Cloud Storage
echo -e "${BLUE}  [*] Checking for Google Cloud Storage references...${NC}"
curl -s "https://${TARGET}" | grep -o '[a-zA-Z0-9.-]*\.storage\.googleapis\.com' | sort -u > "${OUTPUT_DIR}/gcs_buckets.txt" 2>/dev/null
if [ -s "${OUTPUT_DIR}/gcs_buckets.txt" ]; then
    echo -e "${YELLOW}  [!] GCS buckets found - Check permissions${NC}"
    echo "" >> "$REPORT_FILE"
    echo "Google Cloud Storage Buckets Found:" >> "$REPORT_FILE"
    cat "${OUTPUT_DIR}/gcs_buckets.txt" >> "$REPORT_FILE"
fi

echo -e "${GREEN}[✓] Phase 5 completed${NC}\n"

# Final Report Summary
echo "" >> "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════" >> "$REPORT_FILE"
echo "ASSESSMENT COMPLETED" >> "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "All results saved to: ${OUTPUT_DIR}" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "NEXT STEPS:" >> "$REPORT_FILE"
echo "1. Review all findings manually" >> "$REPORT_FILE"
echo "2. Verify any potential vulnerabilities" >> "$REPORT_FILE"
echo "3. Document findings with screenshots" >> "$REPORT_FILE"
echo "4. Prepare detailed proof of concept" >> "$REPORT_FILE"
echo "5. Submit critical findings to appropriate program" >> "$REPORT_FILE"
echo "6. Follow responsible disclosure practices" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Final Banner
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ SECURITY ASSESSMENT COMPLETED SUCCESSFULLY${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Results Summary:${NC}"
echo -e "  Master Report: ${GREEN}${REPORT_FILE}${NC}"
echo -e "  All Results: ${GREEN}${OUTPUT_DIR}${NC}"
echo ""
echo -e "${YELLOW}Priority Review:${NC}"
echo -e "  1. ${RED}Configuration files:${NC} ${OUTPUT_DIR}/*.txt"
echo -e "  2. ${RED}JavaScript secrets:${NC} ${OUTPUT_DIR}/js_scan/FINDINGS.txt"
echo -e "  3. ${YELLOW}API endpoints:${NC} ${OUTPUT_DIR}/api_discovery/"
echo -e "  4. ${YELLOW}Security headers:${NC} ${OUTPUT_DIR}/recon/headers.txt"
echo ""
echo -e "${BLUE}Recommended Actions:${NC}"
echo "  ✓ Review all findings manually"
echo "  ✓ Take screenshots of vulnerabilities"
echo "  ✓ Verify reproducibility of issues"
echo "  ✓ Prepare detailed proof of concept"
echo "  ✓ Follow responsible disclosure timeline"
echo ""

# Check for potential critical findings
echo -e "${PURPLE}Potential Critical Findings Check:${NC}"
CRITICAL_FOUND=false

# Check JavaScript findings
if [ -f "${OUTPUT_DIR}/js_scan/FINDINGS.txt" ] && [ -s "${OUTPUT_DIR}/js_scan/FINDINGS.txt" ]; then
    FINDING_COUNT=$(wc -l < "${OUTPUT_DIR}/js_scan/FINDINGS.txt")
    if [ $FINDING_COUNT -gt 10 ]; then
        echo -e "  ${RED}[!!!] SECRETS FOUND IN JAVASCRIPT - POTENTIAL CRITICAL!${NC}"
        echo -e "  ${RED}      Review: ${OUTPUT_DIR}/js_scan/FINDINGS.txt${NC}"
        CRITICAL_FOUND=true
    fi
fi

# Check for exposed configuration files
if ls ${OUTPUT_DIR}/*env*.txt 1> /dev/null 2>&1; then
    echo -e "  ${RED}[!!!] CONFIGURATION FILE EXPOSED - POTENTIAL CRITICAL!${NC}"
    echo -e "  ${RED}      This may contain sensitive credentials${NC}"
    CRITICAL_FOUND=true
fi

# Check for .git exposure
if [ "$GIT_STATUS" = "200" ]; then
    echo -e "  ${RED}[!!!] .GIT DIRECTORY EXPOSED - CRITICAL FINDING!${NC}"
    echo -e "  ${RED}      Source code may be accessible${NC}"
    CRITICAL_FOUND=true
fi

if [ "$CRITICAL_FOUND" = false ]; then
    echo -e "  ${GREEN}[✓] No obvious critical vulnerabilities detected${NC}"
    echo -e "  ${YELLOW}    (Manual review still recommended)${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Assessment Type:${NC} Black-box Security Testing"
echo -e "${YELLOW}Target:${NC} ${TARGET}"
echo -e "${YELLOW}Program:${NC} ${PROGRAM_NAME}"
echo ""
echo -e "${GREEN}Remember to follow responsible disclosure practices!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Happy Hunting! 🎯"
echo ""
