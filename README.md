# Local-First Hybrid DevOps Infrastructure Pipeline

An enterprise-grade, cost-optimized infrastructure management portfolio built completely within a localized laboratory ecosystem. This repository demonstrates the implementation of a full-scale microservices environment utilizing Infrastructure as Code (IaC), programmatic configuration management baselines, secure version tracking, and Continuous Integration (CI) pipes without incurring active cloud provider resource overhead.

## 🏗️ Architecture Blueprint

```text
       [ Workstation Workspace ]               [ Secure Automated Deployment ]
+------------------------------------+       +---------------------------------+

|  Debian/Kali Laptop                |       |  Local Engine Topology          |
|  * Management Core & Code Editor   |       |                                 |
|  * Terraform Configuration Hooks   | ----> |  Isolated Subnet Network        |
|  * Ansible Hardening Manifests     |       |  (10.10.10.0/24 Bridge Net)     |
|  * Local Git Repository Tracking   |       |               |                 |
+------------------------------------+       |       +-------+-------+         |

                                             |       v               v         |
                                             |  [Frontend]     [Backend Node]  |
                                             |  Nginx Web      Redis Cache DB  |
                                             |  Port 8080      (Dark Subnet)   |
                                             +---------------------------------+
```

## 🛠️ Technology Integration Matrix

- **Infrastructure Engine:** Terraform (v1.6.0+) utilizing custom network drivers to isolate microservice containers dynamically.
- **Configuration Management Engine:** Ansible Core for system-level patch cycles, service state guarantees, and security policies.
- **Virtualization Core:** Docker Daemon managing decoupled frontend routing layers and backend caching layers.
- **Operating System Baselines:** Debian and Kali Linux system kernels.
- **Continuous Integration Pipeline:** GitHub Actions triggering lint testing, configuration mapping tests, and block syntax confirmation on every push.

---

## 🔒 Security Hardening Policies Implemented

To ensure a true zero-trust deployment layout, the following security mechanics are explicitly defined via structural configurations:

1. **Dark Subnet Realities:** The backend Redis database cluster (`10.10.10.25`) is deployed completely devoid of host port maps. It remains unreachable from the outside internet, only receiving traffic originating internally from within the isolated bridge interface.
2. **Cryptographic Only Authentication:** Automated Ansible playbooks rewrite `sshd_config` parameters on the fly, explicitly switching system verification parameters to enforce cryptographic SSH Key-Pairs only.
3. **Attack Surface Reduction:** General interactive entry rules are locked down: `PermitRootLogin` is forced to `no`, and empty, null, or blank user password strings are systemically rejected by the kernel.
4. **Secret Management Prevention:** A strict local `.gitignore` matrix prevents the exposure of binary system states, logs, and sensitive local provider tracking locks (`.terraform.lock.hcl`, `*.tfstate`).

---

## 🚀 Execution & Operational Commands

### 1. Network Subnet Infrastructure Provisioning (IaC)
```bash
cd pi-network/
terraform init      # Downloads the necessary layout provider engines
terraform validate  # Confirms configuration syntax is structurally perfect
terraform plan      # Generates a safe architectural dry-run preview
terraform apply     # Provisions the network, backend node, and public frontend map
```

### 2. Automated OS Patching & Configuration Management
```bash
cd ansible-sysops/
# Execute the playbooks securely with elevated permission callbacks
ansible-playbook -i inventory.ini system_check.yml -K
```

---

## 📈 Strategic Portfolio Engineering Highlights
- **True Declarative Design:** 100% of network architectures and security boundaries are fully versioned, removing human error and "configuration drift."
- **Financial Architecture Acumen:** Designed custom local network drivers to accurately simulate complex multi-cloud VPC subnets, eliminating the dynamic financial overhead of public cloud gateways.
