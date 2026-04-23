# CWL DevOps Internship Assignment
**Submitted by: Rajeswara Rao**

---

All 5 tasks implemented and verified on a local Vagrant-managed Ubuntu VM (VirtualBox, Windows 11 host).

---

## Environment

| Property | Value |
|----------|-------|
| Host OS | Windows 11 |
| Hypervisor | VirtualBox |
| VM Manager | Vagrant |
| VM OS | Ubuntu 22.04 LTS (ubuntu/jammy64) |
| VM Hostname | ubuntu-jammy |
| SSH | 127.0.0.1:2222 via NAT |
| Docker | 29.4.1 |

---

## Repository structure

```
Project-Submission/
├── Task-1/
│   ├── README.md
│   └── screenshot-ssh-login.png
│   ├── sshd_config                # Hardened SSH daemon config
│   ├── ssh_config                 # SSH client shortcut
├── Task-2/
│   ├── Dockerfile
│   ├── README.md
│   ├── index.html
│   ├── screenshot-docker-ps.png
│   └── screenshot-browser.png
├── Task-3/
│   ├── README.md
│   └── screenshot-monitor-logs.png
│   ├── monitor.sh
├── Task-4/
│   ├── README.md
│   └── screenshot-access-control.png
│   ├── setup_monitor_user.sh
├── Task-5/
│   ├── README.md
│   ├── firewall_setup.sh
│   └── screenshot-ufw-status.png
└── README.md
├── Vagrantfile                    # VM config — 2 CPUs, 2GB RAM, port 8000 forwarded
```

---

## Task summary

| # | Task | Tech | Status |
|---|------|------|--------|
| 1 | SSH key-based authentication | OpenSSH, Ed25519 | ✅ |
| 2 | Docker containerization | Docker 29.4.1, nginx:alpine | ✅ |
| 3 | Container resource monitoring | Bash, cron, docker stats | ✅ |
| 4 | Dedicated user + access control | useradd, chmod 700 | ✅ |
| 5 | Firewall | UFW | ✅ |

---

## Quick start

```bash
# SSH into VM
ssh devops-vm

# Build and run the container
cd Task-2/
docker build -t devops-app .
docker run -d --name devops-container -p 8000:80 --restart unless-stopped devops-app

# Set up monitoring (after Task 4 user is created)
sudo cp Task-3/monitor.sh /opt/container-monitor/monitor.sh
sudo crontab -u monitor -e
# add: * * * * * /opt/container-monitor/monitor.sh

# Create monitor user
cd Task-4/ && sudo bash setup_monitor_user.sh

# Configure firewall
cd Task-5/ && sudo bash firewall_setup.sh
```

---

## Implementation notes

**Task 1** — `ssh-copy-id` isn't available on Windows, so the public key was added manually with `echo > authorized_keys`. Used `sshd -T` to verify the daemon actually picked up the config changes, not just that the file was edited.

**Task 2** — Port 8000 is forwarded in the Vagrantfile so the Windows browser can reach the container directly. Hit a CRC mismatch error during the first build (interrupted download) — cleared it with `docker builder prune -f`.

**Task 3** — Script writes two formats: a human-readable `.log` and a `.csv`. The CSV is there in case you want to graph the data or pipe it into something. Cron runs as the `monitor` user, not root.

**Task 4** — Used `--system` flag for `useradd` so the account has no home directory and a UID below 1000. The `/sbin/nologin` shell means nobody can actually log in as this user. Script has a root check at the top so it fails loudly if run without sudo.

**Task 5** — The trusted SSH IP is `10.0.2.2`, which is the VirtualBox NAT gateway — that's how the VM sees the Windows host. Found it with `ip route | grep default`.

---

## Walkthrough video

> **[Link to Video Walkthrough]** — *(Upload to Google Drive and paste link here)*

Covers: SSH passwordless auth → Docker deployment → monitoring logs → access control verification → firewall rules.

---

*CWL DevOps Internship — April 2026*
