#!/bin/bash
# Suricata + OSSEC Integration Setup Script
# Run: curl -sSL https://raw.githubusercontent.com/yourusername/yourrepo/main/setup.sh | bash

sudo apt update && \
sudo apt install -y suricata && \
sudo suricata-update && \
sudo suricata-update enable-source et/open && \
sudo suricata-update && \
RULES=$(grep -c '^alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0) && \
DISABLED=$(grep -c '^# alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0) && \
echo "Active Rules: $RULES | Disabled Rules: $DISABLED" && \
sudo systemctl restart suricata && \
sudo systemctl status suricata --no-pager && \
sudo sed -i '/<ossec_config>/a \  <localfile>\n    <log_format>json<\/log_format>\n    <location>\/var\/log\/suricata\/eve.json<\/location>\n  <\/localfile>' /var/ossec/etc/ossec.conf 2>/dev/null || echo "WARNING: OSSEC not installed, skipping config" && \
echo "✅ Installation complete!"
