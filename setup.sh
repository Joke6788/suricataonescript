#!/bin/bash

# Suricata One-Line Setup Script with Error Fix
# Repository: https://github.com/joke6788/suricataonescript

set -e

echo "🚀 Starting Suricata Installation..."

# Update and Install
sudo apt update
sudo apt install -y suricata

# Update Rules
sudo suricata-update
sudo suricata-update enable-source et/open
sudo suricata-update

# Count Rules
RULES=$(grep -c '^alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0)
DISABLED=$(grep -c '^# alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0)
echo "📊 Active Rules: $RULES | Disabled Rules: $DISABLED"

# Check and Create Config File if Missing
if [ ! -f /etc/suricata/suricata.yaml ]; then
    echo "⚠️ Suricata config missing. Creating default config..."
    
    # Try to copy example config
    if [ -f /usr/share/doc/suricata/examples/suricata.yaml ]; then
        sudo cp /usr/share/doc/suricata/examples/suricata.yaml /etc/suricata/
        echo "✅ Copied example config to /etc/suricata/suricata.yaml"
    else
        # Generate default config
        sudo suricata --init
        echo "✅ Generated default config"
    fi
    
    # Set correct permissions
    sudo chmod 644 /etc/suricata/suricata.yaml
fi

# Restart Suricata
sudo systemctl restart suricata
sudo systemctl status suricata --no-pager

# Configure OSSEC if installed
if [ -f /var/ossec/etc/ossec.conf ]; then
    echo "🔗 Configuring OSSEC integration..."
    sudo sed -i '/<ossec_config>/a \  <localfile>\n    <log_format>json<\/log_format>\n    <location>\/var\/log\/suricata\/eve.json<\/location>\n  <\/localfile>' /var/ossec/etc/ossec.conf
    sudo systemctl restart ossec 2>/dev/null || sudo systemctl restart wazuh-manager 2>/dev/null || echo "ℹ️ OSSEC service restart skipped"
else
    echo "ℹ️ OSSEC not installed, skipping integration"
fi

echo "✅ Setup completed successfully!"
echo ""
echo "📌 Next Steps:"
echo "  1. Configure network interface in /etc/suricata/suricata.yaml"
echo "  2. Check logs: sudo tail -f /var/log/suricata/eve.json | jq '.'"
echo "  3. Test: nmap -sS localhost"
