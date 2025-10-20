# Quick Start Guide

Get started with Universal Web Security Scanner in 5 minutes.

## 🚀 Installation Check

### 1. Verify Files

```bash
cd /home/kali/Documents/etc/universal_web_scanner
ls -la *.sh
```

**Expected output:**
```
-rwxr-xr-x ... master_test.sh
-rwxr-xr-x ... quick_recon.sh
-rwxr-xr-x ... config_hunter.sh
-rwxr-xr-x ... js_secret_scanner.sh
-rwxr-xr-x ... api_discovery.sh
```

### 2. Make Scripts Executable (if needed)

```bash
chmod +x *.sh
```

### 3. Check Required Tools

```bash
which curl grep bash
```

All should return paths. If not:

```bash
sudo apt install -y curl grep bash
```

## Your First Scan

### Step 1: Run Test

```bash
./master_test.sh example.com
```

**What it does:**
- Reconnaissance
- Configuration file hunting
- JavaScript secret scanning
- API discovery
- Security checks

**Duration:** 15-30 minutes

### Step 2: Check for Critical Findings

```bash
# Check JavaScript secrets
cat results/example.com/js_scan/FINDINGS.txt

# Check exposed configs
ls results/example.com/*env*.txt
ls results/example.com/*config*.txt
```

### Step 3: Review Main Report

```bash
cat results/example.com/MASTER_REPORT.txt
```

## Understanding Results

### Directory Structure

```
results/example.com/
├── MASTER_REPORT.txt       Start here
├── recon/                  Reconnaissance data
├── js_scan/
│   └── FINDINGS.txt        Check for secrets!
└── api_discovery/          API endpoints
```

### Critical Findings Indicators

**CRITICAL if found:**
- Files matching `*env*.txt`
- Files matching `*config*.txt`
- Non-empty `js_scan/FINDINGS.txt`
- Git directory exposure

## Common Use Cases

### Use Case 1: Bug Bounty Testing

```bash
# Test target from bug bounty program
./master_test.sh target.hackerone.com "HackerOne"

# Check results
cat results/target.hackerone.com/js_scan/FINDINGS.txt
```

### Use Case 2: Multiple Subdomains

```bash
# Test main domain
./master_test.sh main.company.com "Company Program"

# Test API
./master_test.sh api.company.com "Company Program"

# Test admin panel
./master_test.sh admin.company.com "Company Program"
```

### Use Case 3: Quick Assessment

```bash
# Just reconnaissance
./quick_recon.sh target.com

# Just config hunting
./config_hunter.sh target.com

# Just JavaScript scanning
./js_secret_scanner.sh target.com
```

## What to Look For

### High-Value Findings

1. **Exposed Configuration Files**
   - `/assets/env.js` with credentials
   - `/.env` files
   - `/config.js` with API keys

2. **JavaScript Secrets**
   - OAuth credentials (`client_id`, `client_secret`)
   - API keys (`apiKey`, `api_key`)
   - AWS keys (starting with `AKIA`)
   - JWT tokens (starting with `eyJ`)

3. **Git Exposure**
   - `/.git/config` accessible
   - Source code leak

4. **Sensitive Files**
   - Database backups
   - Configuration backups
   - Credentials files

## Pro Tips

### Tip 1: Test Developer Portals First

```bash
./master_test.sh dev.target.com
./master_test.sh developers.target.com
./master_test.sh portal.target.com
```

**Why:** Often expose API keys and credentials

### Tip 2: Check API Subdomains

```bash
./master_test.sh api.target.com
./master_test.sh api-staging.target.com
./master_test.sh api-dev.target.com
```

**Why:** May have weaker security than production

### Tip 3: Use Browser DevTools

- Open Network tab
- See all JavaScript files loaded
- Verify findings manually

## Important Rules

### DO

- Test only authorized targets
- Use own test accounts
- Verify findings manually
- Report responsibly
- Follow program rules

### DON'T

- Test unauthorized targets
- Perform DoS attacks
- Use credential stuffing
- Access other users' data
- Exploit beyond PoC

## Found Something Critical?

### Immediate Actions

1. **STOP** - Don't exploit further
2. **Screenshot** - Capture evidence
3. **Document** - Write clear steps
4. **Verify** - Confirm in browser
5. **Report** - Submit to program

### Report Should Include

- Clear title
- Vulnerability description
- Impact explanation
- Step-by-step PoC
- Screenshots/video
- Remediation advice

## Example Workflow

### Day 1: Initial Scan

```bash
# Morning: Run automated scan
./master_test.sh target.com "Program Name"

# Afternoon: Review results
cat results/target.com/MASTER_REPORT.txt
cat results/target.com/js_scan/FINDINGS.txt
```

### Day 2: Manual Verification

```bash
# Verify findings in browser
# Take screenshots
# Prepare PoC
```

### Day 3: Reporting

```bash
# Write detailed report
# Submit to bug bounty program
# Follow up
```

## Troubleshooting

### Problem: "Permission denied"

**Solution:**
```bash
chmod +x *.sh
```

### Problem: "curl: command not found"

**Solution:**
```bash
sudo apt install -y curl
```

### Problem: "No results found"

**Possible causes:**
- Target has WAF protection
- No vulnerabilities present
- Need manual testing

**Solution:**
- Try manual browser testing
- Check different endpoints
- Review firewall logs

### Problem: Script hangs

**Solution:**
- Press Ctrl+C to cancel
- Check network connection
- Try individual scripts instead

## Next Steps

After quick start:

1. Read full `README.md`
2. Test on authorized targets only
3. Practice on test environments
4. Join bug bounty platforms
5. Learn from disclosed reports

## Quick Command Reference

```bash
# Full scan
./master_test.sh target.com

# Quick recon
./quick_recon.sh target.com

# Config hunt
./config_hunter.sh target.com

# JS scan
./js_secret_scanner.sh target.com

# API discovery
./api_discovery.sh target.com

# Check results
cat results/target.com/MASTER_REPORT.txt
cat results/target.com/js_scan/FINDINGS.txt
ls results/target.com/*env*.txt
```

## Checklist

Before starting:

- [ ] All scripts present and executable
- [ ] `curl` installed
- [ ] Target authorized for testing
- [ ] Test accounts ready (if needed)
- [ ] Familiar with program rules

## You're Ready!

```bash
cd /home/kali/Documents/etc/universal_web_scanner
./master_test.sh your-target.com
```

**Happy hunting!** 

---

**For detailed documentation:** See `README.md`  
**For troubleshooting:** Check script output messages  
**For support:** Review generated reports and logs

