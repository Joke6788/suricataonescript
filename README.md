
# 🛡️ Suricata One-Line Setup Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Suricata](https://img.shields.io/badge/Suricata-IDS/IPS-EF3B2D?logo=suricata&logoColor=white)](https://suricata.io/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Ubuntu%20%7C%20Debian-blue)](https://ubuntu.com/)

> **One-line script** to automatically install and configure Suricata IDS/IPS with OSSEC integration

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Installation](#-quick-installation)
- [What This Script Does](#-what-this-script-does)
- [Manual Installation](#-manual-installation)
- [Verification](#-verification)
- [Configuration Details](#-configuration-details)
- [Troubleshooting](#-troubleshooting)
- [Uninstallation](#-uninstallation)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This repository provides an automated **one-line script** to set up:
- ✅ **Suricata** - High-performance Network IDS/IPS engine
- ✅ **Emerging Threats (ET/Open)** - Community ruleset
- ✅ **OSSEC Integration** - Forward Suricata alerts to OSSEC HIDS

Perfect for security practitioners who want to quickly deploy network monitoring capabilities with zero configuration hassle.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🚀 **One-Command Setup** | Single line installation (copy-paste ready) |
| 📦 **Auto-Installation** | Installs Suricata with all dependencies |
| 🔄 **Rules Management** | Automatically downloads and updates ET/Open rules |
| 📊 **Rule Statistics** | Shows active/disabled rule counts |
| 🔗 **OSSEC Integration** | Automatically configures OSSEC to read Suricata logs |
| 🔍 **Verification** | Checks Suricata service status |
| ⚡ **Error Handling** | Graceful fallback if OSSEC is not installed |

---

## 📌 Prerequisites

Before running the script, ensure:

| Requirement | Details |
|-------------|---------|
| **OS** | Ubuntu/Debian-based Linux (18.04+, 20.04+, 22.04+) |
| **User** | Root or sudo privileges |
| **Network** | Internet connection (for apt packages & rules) |
| **Disk Space** | Minimum 500MB free |
| **RAM** | Minimum 1GB (2GB+ recommended) |

---

## ⚡ Quick Installation

### Method 1: Direct Run (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/joke6788/suricataonescript/main/setup.sh | sudo bash
```

### Method 2: Download and Run

```bash
wget https://raw.githubusercontent.com/joke6788/suricataonescript/main/setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

### Method 3: One-Liner (Copy & Paste)

```bash
sudo apt update && sudo apt install -y suricata && sudo suricata-update && sudo suricata-update enable-source et/open && sudo suricata-update && RULES=$(grep -c '^alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0) && DISABLED=$(grep -c '^# alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0) && echo "Active Rules: $RULES | Disabled Rules: $DISABLED" && sudo systemctl restart suricata && sudo systemctl status suricata --no-pager && sudo sed -i '/<ossec_config>/a \  <localfile>\n    <log_format>json<\/log_format>\n    <location>\/var\/log\/suricata\/eve.json<\/location>\n  <\/localfile>' /var/ossec/etc/ossec.conf 2>/dev/null && echo "✅ Setup completed successfully!"
```

---

## 🔧 What This Script Does

### Step-by-Step Breakdown

```mermaid
graph LR
    A[Start] --> B[Update APT]
    B --> C[Install Suricata]
    C --> D[Update Rules]
    D --> E[Enable ET/Open]
    E --> F[Update Rules Again]
    F --> G[Count Rules]
    G --> H[Restart Suricata]
    H --> I[Check Status]
    I --> J[Configure OSSEC]
    J --> K[Complete ✅]
```

### Detailed Steps:

1. **Update Package Lists**
   ```bash
   sudo apt update
   ```

2. **Install Suricata**
   ```bash
   sudo apt install -y suricata
   ```

3. **Update Suricata Rules**
   ```bash
   sudo suricata-update
   ```

4. **Enable ET/Open Ruleset**
   ```bash
   sudo suricata-update enable-source et/open
   ```

5. **Final Rules Update**
   ```bash
   sudo suricata-update
   ```

6. **Display Rule Statistics**
   ```bash
   grep -c "^alert" /var/lib/suricata/rules/suricata.rules      # Active rules
   grep -c "^# alert" /var/lib/suricata/rules/suricata.rules    # Disabled rules
   ```

7. **Restart Suricata Service**
   ```bash
   sudo systemctl restart suricata
   ```

8. **Verify Service Status**
   ```bash
   sudo systemctl status suricata
   ```

9. **Integrate with OSSEC** (if installed)
   ```xml
   <localfile>
     <log_format>json</log_format>
     <location>/var/log/suricata/eve.json</location>
   </localfile>
   ```

---

## 📂 Manual Installation

If you prefer to run commands individually:

```bash
# Step 1: Update system
sudo apt update

# Step 2: Install Suricata
sudo apt install -y suricata

# Step 3: Update rules
sudo suricata-update

# Step 4: Enable ET/Open rules
sudo suricata-update enable-source et/open

# Step 5: Update again with new source
sudo suricata-update

# Step 6: Check rules
echo "Active rules: $(grep -c '^alert' /var/lib/suricata/rules/suricata.rules)"
echo "Disabled rules: $(grep -c '^# alert' /var/lib/suricata/rules/suricata.rules)"

# Step 7: Restart Suricata
sudo systemctl restart suricata

# Step 8: Check status
sudo systemctl status suricata

# Step 9: Configure OSSEC (optional)
sudo sed -i '/<ossec_config>/a \  <localfile>\n    <log_format>json<\/log_format>\n    <location>\/var\/log\/suricata\/eve.json<\/location>\n  <\/localfile>' /var/ossec/etc/ossec.conf
```

---

## ✅ Verification

After installation, verify everything is working:

### Check Suricata Status
```bash
sudo systemctl status suricata
```

### Verify Rules
```bash
ls -la /var/lib/suricata/rules/
head -20 /var/lib/suricata/rules/suricata.rules
```

### Check Logs
```bash
sudo tail -f /var/log/suricata/eve.json | jq '.'
```

### Test with Sample Alert
```bash
# Generate a test alert (SSH scan simulation)
nmap -sS localhost
```

### Check OSSEC Integration (if installed)
```bash
sudo tail -f /var/ossec/logs/alerts/alerts.log | grep suricata
```

---

## ⚙️ Configuration Details

### Suricata Configuration
| Setting | Location |
|---------|----------|
| **Config File** | `/etc/suricata/suricata.yaml` |
| **Rules Directory** | `/var/lib/suricata/rules/` |
| **Log Directory** | `/var/log/suricata/` |
| **EVE Log** | `/var/log/suricata/eve.json` (JSON format) |

### OSSEC Integration
| Setting | Location |
|---------|----------|
| **Config File** | `/var/ossec/etc/ossec.conf` |
| **Log Format** | JSON |
| **Log Location** | `/var/log/suricata/eve.json` |

### Network Interface Configuration
After installation, configure Suricata's network interface:

```bash
# Edit config
sudo nano /etc/suricata/suricata.yaml

# Find and change:
af-packet:
  - interface: eth0  # Change to your interface
```

Find your interface:
```bash
ip link show
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **"Permission denied"** | Run with `sudo` or as root |
| **Suricata won't start** | Check config: `sudo suricata -T -c /etc/suricata/suricata.yaml` |
| **Rules not updating** | Check network: `ping rules.emergingthreats.net` |
| **OSSEC config fails** | OSSEC not installed, script will skip gracefully |
| **High memory usage** | Reduce rules: `sudo suricata-update disable-source et/open` |

### Check Suricata Errors
```bash
sudo journalctl -u suricata -f
```

### Validate Configuration
```bash
sudo suricata -T -c /etc/suricata/suricata.yaml
```

### Force Rules Update
```bash
sudo suricata-update --force
```

### Reset Rules
```bash
sudo suricata-update --reset
```

### Restart OSSEC (if configured)
```bash
sudo systemctl restart ossec
```

---

## 🗑️ Uninstallation

### Remove Suricata
```bash
sudo apt remove --purge suricata -y
sudo apt autoremove -y
sudo rm -rf /etc/suricata /var/lib/suricata /var/log/suricata
```

### Remove OSSEC Integration
```bash
sudo sed -i '/<localfile>/,/<\/localfile>/d' /var/ossec/etc/ossec.conf
sudo systemctl restart ossec
```

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing`)
5. **Open** a Pull Request

### Guidelines
- ⚡ Keep it **one-line** compatible
- 📝 Update documentation
- ✅ Test on Ubuntu/Debian
- 🔒 Security-first mindset

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Suricata Project](https://suricata.io/) - IDS/IPS engine
- [Emerging Threats](https://rules.emergingthreats.net/) - Community ruleset
- [OSSEC Project](https://www.ossec.net/) - Host-based IDS
- [Wazuh](https://wazuh.com/) - OSSEC fork (alternative)

---

## 📞 Support

| Channel | Link |
|---------|------|
| **Issues** | [GitHub Issues](https://github.com/joke6788/suricataonescript/issues) |
| **Discussions** | [GitHub Discussions](https://github.com/joke6788/suricataonescript/discussions) |
| **Repository** | [GitHub Repo](https://github.com/joke6788/suricataonescript) |

---

## 🌟 Star History

If you find this useful, please ⭐ star the repository!

[![Star History Chart](https://api.star-history.com/svg?repos=joke6788/suricataonescript&type=Date)](https://star-history.com/#joke6788/suricataonescript&Date)

---

## 📊 Quick Reference Card

```bash
# 🚀 Install
curl -sSL https://raw.githubusercontent.com/joke6788/suricataonescript/main/setup.sh | sudo bash

# 🔍 Check Status
sudo systemctl status suricata

# 📊 View Logs
sudo tail -f /var/log/suricata/eve.json | jq '.'

# 🔄 Update Rules
sudo suricata-update

# 🔧 Restart Service
sudo systemctl restart suricata

# 🗑️ Uninstall
sudo apt remove --purge suricata -y
```

---

## 📝 Script File Structure

```
suricataonescript/
├── setup.sh          # Main installation script
├── README.md         # Documentation (this file)
└── LICENSE           # MIT License (optional)
```

---

**Made with ❤️ for the Security Community**

---

*Last Updated: June 2026*
