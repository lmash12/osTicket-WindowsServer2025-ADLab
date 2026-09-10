# Enterprise IT Service Desk & Active Directory Integration Lab

![Windows Server 2025](https://img.shields.io/badge/OS-Windows%20Server%202025-blue?style=flat&logo=windows)
![osTicket](https://img.shields.io/badge/Ticketing-osTicket%20v1.18.4-orange)
![IIS](https://img.shields.io/badge/Web%20Server-IIS%2010.0-lightgrey)
![PHP](https://img.shields.io/badge/PHP-8.5-777BB4?logo=php)
![MySQL](https://img.shields.io/badge/Database-MySQL%208.0-4479A1?logo=mysql)

A complete production-grade implementation of an enterprise IT Service Desk running **osTicket v1.18.4** on **Windows Server 2025 (`novexus.local`)**. This project demonstrates end-to-end IT service management, active user provisioning via PowerShell, LDAPS domain authentication, automated task scheduling, SLA tracking, and disaster recovery database backups.

---

# Architecture & Infrastructure Overview

* **Domain Controller / OS:** Windows Server 2025 (`novexus.local`)
* **Web Server:** IIS 10.0 with URL Rewrite 2.1 & FastCGI
* **Database Engine:** MySQL Server 8.0 / MariaDB 10.11
* **Runtime Environment:** PHP 8.5 (configured with `ldap`, `mysqli`, `gd`, `opcache`, `mbstring`)
* **Authentication Protocol:** Secure LDAP (LDAPS over Port 636 / 389)
* **Automation Engines:** Windows Task Scheduler triggering `cron.php` and automated weekly database dumps

---

# Key Features & Automated Workflows

# 1. Automated AD User Onboarding Pipeline
* **Bulk Provisioning:** Utilizes `Bulk-OnboardUsers.ps1` to parse `ADUsers.csv` and auto-provision domain users into target Organizational Units (`OU=Novexus Workloads,DC=novexus,DC=local`).
* **Ticket Generation:** Integrates `New User OnboardingTicket.ps1.txt` to automatically dispatch welcome and setup tickets into osTicket upon user account creation.

# 2. Active Directory & LDAPS Synchronization
* Configured osTicket LDAP/Active Directory plugin for Single Sign-On (SSO) and client authentication.
* Staff and clients authenticate using native domain credentials (`username@novexus.local`).

# 3. Automated Ticket Routing & SLA Management
* Ticket Filters automatically route incoming requests based on user metadata and subject lines to designated departments (e.g., IT Support, Systems Administration).
* Enforces custom SLA plans (Emergency, 24/7, Standard) with automated background execution via Windows Task Scheduler executing `cron.php` every 5 minutes.

# 4. Operational Efficiency & Productivity
* Configured Canned Responses with dynamic placeholder variables (`%{ticket.user.first_name}`, `%{ticket.user.username}`) for rapid agent incident handling.

# 5. Automated Disaster Recovery & Backups
* Weekly automated MySQL database backup (`Backup-osTicket.ps1` / `osTicket Database Backup.xml`) executed via Task Scheduler at 12:00 AM, dumping the database, generating a compressed `.zip` archive, and logging execution output.

---

# Repository Structure

```text
├── docs/
│   └── images/                       # Proof-of-work deployment screenshots
│       ├── 01-ldaps ad configurations.PNG
│       ├── 02-task scheduler actions.PNG
│       ├── 03-system logs cron execution.PNG
│       ├── 04-ticket filter routing.PNG
│       ├── 05-clientportal ad login.png.png
│       ├── 06-active ticket queue.png
│       ├── 07-canned response execution.png
│       ├── 08-dashboard metrics overview.png
│       ├── database backup.png
│       └── os database backup.png
├── scripts/
│   ├── ADUsers.csv                    # CSV template for bulk user provisioning
│   ├── Bulk-OnboardUsers.ps1          # Active Directory bulk onboarding script
│   ├── New User OnboardingTicket.ps1.txt # Automated ticket generation script
│   ├── osTicket Cron Job.xml          # Task Scheduler XML export for cron.php
│   ├── osTicket Database Backup.xml   # Task Scheduler XML export for nightly backups
│   ├── php-extensions-config.ini      # Optimized PHP extension configurations
│   └── web.config                     # IIS web server configuration file
└── README.md                          # Project documentation
```text
#Technical Troubleshooting Log
During deployment on Windows Server 2025 and IIS 10, several enterprise environmental issues were identified and resolved:
### 1.PHP CLI Execution in Task Scheduler:
* Issue: cron.php failed to execute via Task Scheduler due to relative pathing errors.
* Fix: Configured absolute path calling in Task Scheduler action: C:\tools\php85\php.exe -f "C:\inetpub\wwwroot\osticket\api\cron.php"
### 2. IIS URL Rewrite & FastCGI Pathing:
* Issue: HTTP 404 errors on API endpoints and client login redirects.
* Fix: Imported custom rewrite rules into web.config and enabled cgi.fix_pathinfo=1 in php.ini.
### 3. MySQL Backup Script Execution:
* Issue: mysqldump.exe path mismatch during scheduled task execution.
* Fix: Built dynamic path resolution logic into Backup-osTicket.ps1 to automatically locate binary installations across standard MySQL/MariaDB paths.
