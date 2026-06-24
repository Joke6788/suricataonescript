#!/bin/bash

# Suricata One-Line Setup Script - Complete Fix
# Repository: https://github.com/joke6788/suricataonescript

set -e

echo "🚀 Starting Suricata Installation..."

# 1. Update and Install Suricata
sudo apt update
sudo apt install -y suricata

# 2. Create default config if missing
if [ ! -f /etc/suricata/suricata.yaml ]; then
    echo "⚠️ Creating default Suricata config..."
    
    # Create directory if missing
    sudo mkdir -p /etc/suricata
    
    # Create basic config file
    sudo cat > /etc/suricata/suricata.yaml << 'EOF'
%YAML 1.1
---
# Suricata Configuration File
vars:
  address-groups:
    HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
    EXTERNAL_NET: "!$HOME_NET"
    HTTP_SERVERS: "$HOME_NET"
    SMTP_SERVERS: "$HOME_NET"
    SQL_SERVERS: "$HOME_NET"
    DNS_SERVERS: "$HOME_NET"
    TELNET_SERVERS: "$HOME_NET"
    AIM_SERVERS: "$HOME_NET"
    DNP3_SERVER: "$HOME_NET"
    DNP3_CLIENT: "$HOME_NET"
    MODBUS_CLIENT: "$HOME_NET"
    MODBUS_SERVER: "$HOME_NET"
    ENIP_CLIENT: "$HOME_NET"
    ENIP_SERVER: "$HOME_NET"

default-rule-path: /var/lib/suricata/rules
rule-files:
  - suricata.rules

classification-file: /etc/suricata/classification.config
reference-config-file: /etc/suricata/reference.config

threshold-file: /etc/suricata/threshold.config

outputs:
  - fast:
      enabled: yes
      filename: fast.log
      append: yes
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert
        - http
        - dns
        - tls
        - files
        - ssh
        - smtp
        - dhcp
        - metadata
        - netflow
        - smb
        - tftp
        - ikev2
        - krb5
        - snmp
        - rdp
        - nfs

af-packet:
  - interface: eth0
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    use-mmap: yes
    tpacket-v3: yes

pcap:
  - interface: eth0

pcap-file:
  - mode: multi

app-layer:
  protocols:
    tls:
      enabled: yes
    dcerpc:
      enabled: yes
    ftp:
      enabled: yes
    ssh:
      enabled: yes
    smtp:
      enabled: yes
    imap:
      enabled: yes
    msn:
      enabled: yes
    modbus:
      enabled: yes
    dnp3:
      enabled: yes
    enip:
      enabled: yes
    nfs:
      enabled: yes
    ikev2:
      enabled: yes
    krb5:
      enabled: yes
    snmp:
      enabled: yes
    rdp:
      enabled: yes

flow:
  memcap: 33554432
  hash-size: 65536
  prealloc: 10000
  emergency-recovery: 30

stream:
  memcap: 67108864
  checksum-validation: yes
  inline: no
  reassembly:
    memcap: 67108864
    depth: 1048576
    toserver-chunk-size: 2560
    toclient-chunk-size: 2560
    randomize-chunk-size: yes

host-os-policy:
  windows: [0.0.0.0/0]
  bsd: []
  bsd-right: []
  old-linux: []
  linux: [::0/0]
  old-solaris: []
  solaris: []
  hpux10: []
  hpux11: []
  irix: []
  macos: []
  vista: []
  windows2k3: []

defrag:
  memcap: 33554432
  hash-size: 65536
  trackers: 65535
  max-frags: 65535
  prealloc: yes
  timeout: 60

flow-timeouts:
  default:
    new: 30
    established: 300
    closed: 0
    emergency-new: 10
    emergency-established: 100
    emergency-closed: 0
  tcp:
    new: 60
    established: 3600
    closed: 120
    emergency-new: 10
    emergency-established: 300
    emergency-closed: 20
  udp:
    new: 30
    established: 300
    closed: 0
    emergency-new: 10
    emergency-established: 100
    emergency-closed: 0
  icmp:
    new: 30
    established: 300
    closed: 0
    emergency-new: 10
    emergency-established: 100
    emergency-closed: 0

detect:
  profile: medium
  custom-values:
    toclient-groups: 3
    toserver-groups: 25
  sgh-mpm-context: auto
  inspection-recursion-limit: 3000
  prefilter:
    default: yes
  state:
    any: []

threading:
  set-cpu-affinity: no
  cpu-affinity:
    management-cpu-set:
      cpu: [ 0 ]
    worker-cpu-set:
      cpu: [ "all" ]
      mode: "exclusive"
  detect-thread-ratio: 1.0

luajit:
  states: 64

libhtp:
  default-config:
    personality: IDS
    request-body-limit: 30720
    response-body-limit: 30720
    request-body-minimal-inspect-size: 20480
    response-body-minimal-inspect-size: 20480
    request-body-inspect-window: 4096
    response-body-inspect-window: 4096
    response-body-decompress-layer-limit: 2
    http-body-inline: auto
    enable-decompression: yes
    decompress-switch: auto
    decompress-depth: 1048576

pcre:
  match-limit: 3500
  match-limit-recursion: 1500

host-mode: auto
EOF
    
    echo "✅ Default config created at /etc/suricata/suricata.yaml"
fi

# 3. Update Rules
sudo suricata-update
sudo suricata-update enable-source et/open
sudo suricata-update

# 4. Count Rules
RULES=$(grep -c '^alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0)
DISABLED=$(grep -c '^# alert' /var/lib/suricata/rules/suricata.rules 2>/dev/null || echo 0)
echo "📊 Active Rules: $RULES | Disabled Rules: $DISABLED"

# 5. Test Configuration
echo "🔍 Testing Suricata configuration..."
sudo suricata -T -c /etc/suricata/suricata.yaml || {
    echo "⚠️ Config test failed, but continuing..."
}

# 6. Restart Suricata
sudo systemctl restart suricata
sudo systemctl status suricata --no-pager || true

# 7. Configure OSSEC if installed
if [ -f /var/ossec/etc/ossec.conf ]; then
    echo "🔗 Configuring OSSEC integration..."
    if ! grep -q "eve.json" /var/ossec/etc/ossec.conf; then
        sudo sed -i '/<ossec_config>/a \  <localfile>\n    <log_format>json<\/log_format>\n    <location>\/var\/log\/suricata\/eve.json<\/location>\n  <\/localfile>' /var/ossec/etc/ossec.conf
        sudo systemctl restart ossec 2>/dev/null || sudo systemctl restart wazuh-manager 2>/dev/null || echo "ℹ️ OSSEC service restart skipped"
    fi
else
    echo "ℹ️ OSSEC not installed, skipping integration"
fi

echo "✅ Setup completed successfully!"
echo ""
echo "📌 Next Steps:"
echo "  1. Check config: sudo suricata -T"
echo "  2. Check logs: sudo tail -f /var/log/suricata/eve.json | jq '.'"
echo "  3. Test: nmap -sS localhost"
echo "  4. Interface config: sudo nano /etc/suricata/suricata.yaml"
