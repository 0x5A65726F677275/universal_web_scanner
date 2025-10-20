# Universal Web Security Scanner

Comprehensive automated security testing toolkit for web applications and bug bounty programs.

## Overview

Professional security testing suite designed to discover high-value vulnerabilities including:
- Exposed credentials and API keys
- Configuration file leaks
- JavaScript secret exposure
- API security issues
- Authentication vulnerabilities

## Quick Start

### Basic Usage

```bash
# Test any domain
./master_test.sh target.com

# With program name
./master_test.sh target.com "Bug Bounty Program"
```

### Examples

```bash
# Test developer portal
./master_test.sh dev.example.com "HackerOne"

# Test API endpoint
./master_test.sh api.example.com "Bugcrowd"

# Test main application
./master_test.sh app.company.com "Private Program"
```

## Required Files

### Essential Scripts (All Included)

```
master_test.sh           - Main orchestrator
quick_recon.sh           - Reconnaissance
config_hunter.sh         - Configuration file hunter
js_secret_scanner.sh     - JavaScript secret scanner
api_discovery.sh         - API discovery tool
```

### System Requirements

**Minimum (Required):**
- `curl`
- `grep`
- `bash`

**Recommended (Optional):**
- `whatweb` - Technology detection
- `nmap` - Port scanning
- `wafw00f` - WAF detection
- `nikto` - Vulnerability scanner
- `openssl` - SSL/TLS analysis
- `dig` - DNS queries

### Install Tools (Debian/Kali)

```bash
# Minimum
sudo apt install -y curl grep bash

# Recommended
sudo apt install -y whatweb nmap wafw00f nikto openssl dnsutils
```

## Available Tools

### 1. Master Test Suite (Recommended)

**File:** `master_test.sh`

Complete automated assessment running all phases.

```bash
./master_test.sh target.com "Program Name"
```

**Duration:** 15-30 minutes per target

**Phases:**
1. Reconnaissance (DNS, tech stack, WAF)
2. Configuration file hunting
3. JavaScript secret scanning
4. API discovery and testing
5. Additional security checks

---

### 2. Quick Reconnaissance

**File:** `quick_recon.sh`

Fast initial reconnaissance.

```bash
./quick_recon.sh target.com
```

**Discovers:**
- DNS information
- Technology stack
- WAF/CDN detection
- Security headers
- SSL/TLS configuration
- Common endpoints

---

### 3. Configuration File Hunter

**File:** `config_hunter.sh`

Searches for exposed configuration files.

```bash
./config_hunter.sh target.com
```

**Targets:**
- `/assets/env.js`
- `/config.js`
- `/.env`
- `/web.config`
- And 15+ more paths

**Searches for:**
- OAuth credentials
- API keys
- Secrets and tokens
- Payment API credentials

**High-value findings likely!**

---

### 4. JavaScript Secret Scanner

**File:** `js_secret_scanner.sh`

Scans JavaScript files for embedded secrets.

```bash
./js_secret_scanner.sh target.com
```

**Detects:**
- OAuth Client IDs and Secrets
- API Keys
- JWT Tokens
- AWS Access Keys
- Private Keys
- Database URLs
- Payment endpoints

**Critical vulnerability finder!**

---

### 5. API Discovery Tool

**File:** `api_discovery.sh`

Discovers and tests API security.

```bash
./api_discovery.sh target.com
```

**Tests:**
- API endpoint enumeration
- GraphQL introspection
- Swagger/OpenAPI docs
- CORS misconfigurations
- Security headers
- Rate limiting

---

## Output Structure

All results saved to `results/[domain]/`:

```
results/
└── target.com/
    ├── MASTER_REPORT.txt       Main report
    ├── recon/
    │   ├── dns.txt
    │   ├── whatweb.txt
    │   └── headers.txt
    ├── js_scan/
    │   ├── FINDINGS.txt        Check for secrets!
    │   ├── api_endpoints.txt
    │   └── internal_urls.txt
    ├── api_discovery/
    │   ├── api_endpoints.txt
    │   └── cors_test.txt
    └── [config files].txt      Exposed configs
```

##  Finding Critical Vulnerabilities

### Priority Check After Each Test

#### 1. Configuration Files (Highest Priority)

```bash
ls results/[target]/*env*.txt
ls results/[target]/*config*.txt
```

**If found:** Likely critical vulnerability

#### 2. JavaScript Secrets

```bash
cat results/[target]/js_scan/FINDINGS.txt
```

**Look for:**
- `client_id` / `client_secret`
- `api_key` / `apiKey`
- `AKIA...` (AWS keys)
- `eyJ...` (JWT tokens)
- OAuth domains (okta.com, auth0.com)

#### 3. Git Exposure

```bash
grep -i "git directory exposed" results/[target]/MASTER_REPORT.txt
```

**If found:** Critical vulnerability

#### 4. Review Main Report

```bash
cat results/[target]/MASTER_REPORT.txt
```

## Usage Scenarios

### Scenario 1: New Bug Bounty Program

```bash
# Full assessment
./master_test.sh target.com "Program Name"

# Check results
cat results/target.com/js_scan/FINDINGS.txt
ls results/target.com/*env*.txt

# Manual verification
# (Verify findings in browser)
```

### Scenario 2: Multiple Subdomains

```bash
# Test each subdomain
./master_test.sh main.target.com "Program"
./master_test.sh api.target.com "Program"
./master_test.sh admin.target.com "Program"
./master_test.sh dev.target.com "Program"
```

### Scenario 3: Quick Initial Assessment

```bash
# Quick recon only
./quick_recon.sh target.com

# Config check only
./config_hunter.sh target.com

# JS scan only
./js_secret_scanner.sh target.com
```

##  Pro Tips

### 1. Test High-Value Targets First

```bash
./master_test.sh dev.target.com      # Developer portals
./master_test.sh api.target.com      # API servers
./master_test.sh admin.target.com    # Admin panels
```

**Why:** Higher likelihood of finding credentials

### 2. Focus on APIs

```bash
./master_test.sh api.target.com
./master_test.sh api-staging.target.com
./master_test.sh api-dev.target.com
```

**Why:** Often less secure than production

### 3. Check Developer Resources

```bash
./master_test.sh developers.target.com
./master_test.sh portal.target.com
./master_test.sh docs.target.com
```

**Why:** May expose API keys and documentation

## Testing Guidelines

### Allowed

- In-scope domains only
- Own test accounts
- Passive reconnaissance
- Manual verification
- Responsible disclosure

### Prohibited

- Out-of-scope domains
- DoS/DDoS attacks
- Credential stuffing
- Automated mass scanning
- Other users' data
- Data exfiltration

## Bug Bounty Programs

### HackerOne

```bash
./master_test.sh target.com "HackerOne"
```

- Check for duplicates
- Clear PoC required
- CVSS scoring recommended

### Bugcrowd

```bash
./master_test.sh target.com "Bugcrowd"
```

- Use VRT taxonomy
- Accurate priority setting
- Clear impact description

### Intigriti

```bash
./master_test.sh target.com "Intigriti"
```

- GDPR considerations
- Clear English reports
- Video PoC preferred

## Customization

### Adjust Timeouts

Edit scripts to change `sleep` values:

```bash
sleep 2  # Change to sleep 5 for slower scanning
```

### Add Custom Paths

In `config_hunter.sh`, add to `CONFIG_PATHS` array:

```bash
CONFIG_PATHS=(
    "/assets/env.js"
    "/config.js"
    # Add custom paths here
    "/custom/path/config.json"
)
```

## Expected Results

### Per Target

- **Testing time:** 15-30 minutes (automated)
- **Review time:** 30-60 minutes (manual)
- **Report time:** 1-3 hours (if findings)

### Success Metrics

**Realistic:**
- 3-10 vulnerabilities of various severity
- 1-2 high-impact findings

**Optimistic:**
- 1+ critical vulnerability
- Multiple high-severity findings

## When You Find Critical Vulnerabilities

### Immediate Steps

1. **STOP** - Don't exploit further
2. **Document** - Take screenshots
3. **Verify** - Confirm it's real
4. **Report** - Submit to program
5. **Follow up** - Responsible disclosure

### Evidence Required

1. Clear title and description
2. Step-by-step reproduction
3. Screenshots/video proof
4. Business impact explanation
5. Remediation recommendations

## Report Template

### Critical Finding Structure

```markdown
# Title
[Clear, concise vulnerability description]

## Description
[What is vulnerable]

## Impact
[Why it matters]

## Proof of Concept
[Step-by-step reproduction]

## Recommendations
[How to fix]
```

## Troubleshooting

### Error: "Permission denied"

```bash
chmod +x *.sh
```

### Error: "Script not found"

```bash
# Ensure you're in correct directory
cd /home/kali/Documents/etc/universal_web_scanner
ls -la *.sh
```

### Warning: "Tool not found: whatweb"

```bash
# Install recommended tools
sudo apt install -y whatweb nmap wafw00f
```

### No Results Found

- Target may have WAF protection
- Try manual testing with browser
- Check different paths manually
- Use VPN if rate limited

## Resources

### Bug Bounty Platforms

- HackerOne: https://hackerone.com
- Bugcrowd: https://bugcrowd.com
- Intigriti: https://intigriti.com
- YesWeHack: https://yeswehack.com

### Learning Resources

- OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
- API Security Top 10: https://owasp.org/www-project-api-security/
- PortSwigger Academy: https://portswigger.net/web-security

## Pre-Flight Checklist

Before testing:

- [ ] All 5 scripts present
- [ ] Scripts are executable (`chmod +x *.sh`)
- [ ] `curl` installed
- [ ] Target is in-scope
- [ ] Authorization obtained
- [ ] Test accounts ready (if needed)

## Quick Reference

### Essential Commands

```bash
# Full test
./master_test.sh target.com

# Check for critical findings
cat results/target.com/js_scan/FINDINGS.txt
ls results/target.com/*env*.txt

# View report
cat results/target.com/MASTER_REPORT.txt
```

### File Checklist

```
 master_test.sh
 quick_recon.sh
 config_hunter.sh
 js_secret_scanner.sh
 api_discovery.sh
```

## Support

For issues:
1. Check script output for errors
2. Verify tool installation
3. Review generated reports
4. Test manually if automated fails

## Success Formula

1. **Developer portals first** - High credential exposure likelihood
2. **JavaScript scanning** - Essential for finding secrets
3. **Configuration checks** - Critical findings likely
4. **Manual verification** - Always confirm automated findings
5. **Clear reporting** - Professional documentation

---

**Ready to scan!** 

**Location:** `/home/kali/Documents/etc/universal_web_scanner`

**First command:** `./master_test.sh target.com`

---

## Version

**v1.0** - Universal Web Security Scanner  
**Updated:** October 2025  
**License:** For authorized security testing only

