
## Lab Deployment & Daily Verification Runbook

This guide details the exact sequential steps required to bring the multi-node engineering lab from a powered-down state to full operational status, followed by infrastructure validation checks.

### Phase 1: Infrastructure Boot Sequence

Follow this exact boot order to ensure dependencies (like DNS and authentication realms) are ready before client nodes attempt connections.

1. **Power on the Core Domain Controller:**
   * Physically boot the Raspberry Pi 4 (`10.0.0.164`).
   * Ensure the Ethernet link light is solid.
   
2. **Boot the Debian Linux Host Laptop:**
   * Power on the laptop and log into your local environment.
   * Verify the machine establishes its Wi-Fi network connection.

3. **Spin Up Virtual Environments (If Needed):**
   * If running lab testing instances, launch your KVM hypervisor management tool and start your infrastructure VMs (`Debian-Automation-Gateway`, `win2k22`).

---

### Phase 2: Live Service Verification

Once all physical and virtual nodes are powered on, execute these rapid verification checks from the **Debian Host Laptop** terminal to ensure the environment is healthy.

#### Step 1: Confirm Host Interface Configuration
Verify that the primary Wi-Fi connection profile is actively routing queries to the private Domain Controller for private realm lookups.
```bash
cat /etc/resolv.conf
```
* **Expected Output:** `nameserver 10.0.0.164` must be present at the top of the nameserver list.

#### Step 2: Native Active Directory SRV Record Lookups
Confirm that the cross-node lookup path to the Samba AD database is working without requiring forced IP configurations.
```bash
host -t SRV _ldap._tcp.corp.internal
```
* **Expected Output:** `_ldap._tcp.corp.internal has SRV record 0 100 389 dc1.corp.internal.`

#### Step 3: Check Share Enumeration via RPC
Validate cross-platform network authentication using your Active Directory domain account credentials.
```bash
smbclient -L //10.0.0.164 -U yovanny
```
* **Expected Action:** Enter your domain password when prompted.
* **Expected Output:** A clean list of hosted SMB shares including `sysvol`, `netlogon`, and `LabShare`.

---

### Phase 3: Automated Pipeline Monitoring

Execute the centralized automation script to verify the health of local intrusion detection logging and network endpoints.

1. Run the health check framework using system privileges:
   ```bash
   sudo ./check_lab_health.sh
   ```
2. Inspect the consolidated monitoring log dashboard to ensure all components report `[OK]`:
   ```bash
   cat /var/log/lab_health.log
   ```

* **Target Health Metrics to Verify:**
  * `[OK] Suricata Service is running.`
  * `[OK] EveBox Local Agent is running.`
  * `[OK] eve.json is actively updating.`
  * `[OK] Raspberry Pi DC (10.0.0.164) is reachable.`
  * `[OK] Active Directory DNS resolution for corp.internal is working.`
