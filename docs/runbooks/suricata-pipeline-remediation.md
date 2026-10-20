# Runbook: Suricata Pipeline Remediation & Active Directory Signature Deployment
**Author:** Yovanny Cenobio  
**Repository:** devops-infrastructure  
**Environment:** Hybrid Engineering Lab (Debian Laptop Router, Hardened Windows Server 2022 KVM VM, Headless Raspberry Pi 4 Sensor Array)

---

## 1. Executive Summary & Architecture Breakdown
This document chronicles the diagnostic deep-dive, remediation, and operational extension of the decentralized network security monitoring (NSM) data pipeline. The architecture seamlessly links a virtual hypervisor processing environment with an external physical sensor platform:
* **Endpoint / Target:** Windows Server 2022 VM (`win2k22` at `10.10.10.10`) sitting on a native isolated KVM bridge (`br-prod-iso`).
* **Router / Gateway:** Native Debian Workstation acting as the perimeter firewall (`10.10.10.1`).
* **SIEM / Management Console:** Centralized EveBox server deployed on a physical, headless Raspberry Pi 4 appliance (`dc1` at `10.0.0.164` listening on port `5636`).

---

## 2. Problem Statement
During initial lab deployments, custom network-side validation rules (specifically `SID 1000001` for ICMP Ping Tracking) failed to populate the central EveBox dashboard despite continuous network operations. A systematic review isolated an ingestion failure at the hypervisor layer and a transport-level authentication conflict across the network interface.

---

## 3. Diagnostic & Remediation Methodology

### 3.1 Network Packet Verification
To confirm that raw traffic was hitting the network interface cards, an isolated packet capture was executed on the host workstation:
```bash
sudo tcpdump -i br-prod-iso icmp -nn -vv
```
*Result:* Confirmed clean bidirectional `ICMP echo request` and `reply` exchanges traversing the virtual bridge, establishing that the physical data link layer was fully operational.

### 3.2 Ingestion Engine Repair
Audit logs revealed that Suricata was omitting custom local signatures due to default ingestion constraints. 
1. The absolute rule track path was explicitly appended to the `rule-files:` layout block inside `/etc/suricata/suricata.yaml`:
   ```yaml
   rule-files:
     - suricata.rules
     - /etc/suricata/rules/local.rules
   ```
2. Ran a verification test to eliminate path anomalies and validate engine parameters:
   ```bash
   sudo suricata -T -c /etc/suricata/suricata.yaml -v
   ```
3. Loaded signatures live into kernel memory: `sudo systemctl restart suricata`.

### 3.3 Log Forwarding Pipeline Encryption
The EveBox agent was throwing WebSocket exceptions because it was attempting plain text communication against a remote collector requiring TLS.
The pipeline was stabilized by introducing a dedicated background systemd task (`evebox-agent-local.service`) that enforces strict HTTPS wrappers paired with individual server token verification:
```bash
sudo EVEBOX_SERVER_KEY=eba_ivowioPtk5QIXs6EaRIMHH3pLTSngz1JeEKBKtU1jzo /usr/local/bin/evebox agent --server https://10.0.0.164:5636 --disable-certificate-check /var/log/suricata/eve.json
```

---

## 4. Operational Health & Automation
To preserve continuous system visibility with minimal hardware resource draw, a dedicated, automated cron utility was established to execute an hourly system check script (`check_lab_health.sh`) tracking service run-states and dumping heartbeats to `/var/log/lab_health.log`.

---

## 5. Active Directory SMB Brute-Force Monitoring Extension

### 5.1 Threat Context & Design Logic
To complement the account security Group Policy Objects (GPOs) enforced on the `win2k22` Domain Controller, an advanced behavioral signature was designed to detect automated brute-force attacks over **Port 445 (SMB)** while filtering routine network background noise.

### 5.2 Signature Configuration
The following threshold-limited detection rule was appended to `/etc/suricata/rules/local.rules`:
```text
alert tcp any any -> 10.10.10.10 445 (msg:"ATTACK - Active Directory SMB Brute Force Attempt"; flags:S,12; threshold:type threshold, track by_src, count 30, seconds 10; sid:1000003; rev:1;)
```
* **Protocol Control:** Targets synchronization handshakes (`flags:S`) heading to the AD authentication listener.
* **Rate Thresholding:** Suppresses individual errors, only firing a high-priority alert if a single source IP initiates **30 connection attempts within 10 seconds**.

### 5.3 Automated Validation Simulation
A socket loop was executed from the Debian router to force rapid connection attempts and test the threshold boundaries:
```bash
for i in {1..35}; do timeout 0.1 bash -c "echo > /dev/tcp/10.10.10.10/445" 2>/dev/null; done
```
*Outcome:* The loop successfully tripped the signature, seamlessly routing real-time alerts through the encrypted log agent to display the event signature: **`ATTACK - Active Directory SMB Brute Force Attempt`** on the central console.

## 6. Advanced Extension: TCP Stealth Port-Scan Detection

### 6.1 Threat Context & Design Logic
To mitigate initial network reconnaissance and mapping operations (e.g., Nmap stealth scans), a behavioral rule was created to flag automated port sweeping. This signature targets half-open handshake attempts designed to bypass traditional application layer log files.

### 6.2 Signature Configuration
The following threshold rule was added to `/etc/suricata/rules/local.rules`:
```text
alert tcp any any -> 10.10.10.0/24 any (msg:"ATTACK - TCP Stealth Port Scan Detected"; flags:S; threshold:type threshold, track by_src, count 30, seconds 5; sid:1000002; rev:1;)
```
* **Traffic Control:** Monitors the complete isolated internal subnet (`10.10.10.0/24`) across any inbound port destination matrix.
* **Behavioral Thresholding:** Utilizes a tight tracking window (`seconds 5`) to ignore normal network behavior, only firing a warning if a single scanner host (`track by_src`) initiates **30 unique SYN-only handshakes**.

### 6.3 Automated Validation Simulation
To cross the behavioral counting floor, a rapid sequential port loop was executed from the laptop gateway interface:
```bash
for port in {1..35}; do timeout 0.05 bash -c "echo > /dev/tcp/10.10.10.10/\$port" 2>/dev/null; done
```

### 6.4 Operational Outcome
The execution successfully tripped the threshold matrix. The local logging engine appended the alert to `eve.json`, and the background systemd agent instantly piped it to the central management dashboard to render the event profile: **`ATTACK - TCP Stealth Port Scan Detected`**.
