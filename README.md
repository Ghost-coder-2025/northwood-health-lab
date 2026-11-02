# Northwood Regional Health — Simulated IT Infrastructure Lab

## Project Purpose

This project simulates the IT infrastructure of a regional healthcare organization to demonstrate hands-on systems administration skills, including Active Directory deployment, Organizational Unit (OU) design, user/group provisioning, and Group Policy (GPO) management.

## Scope & Disclaimer

Northwood Regional Health is a **fictional organization** created solely for this lab. All user accounts, patient counts, and organizational details are simulated for demonstration purposes. No real patient data (PHI) or real organizational data is used at any point in this project.

## Organization Profile

Northwood Regional Health is a fictional regional healthcare network consisting of one main hospital and two satellite clinics, serving approximately 45,000 patients annually. The organization employs roughly 350 staff. This lab simulates a scaled-down but representative subset of Northwood's IT infrastructure — approximately 40-50 user accounts, a domain controller, and departmental OU/GPO structures — reflecting the access controls and administrative practices typical of a HIPAA-adjacent healthcare environment.

### Departments

| Department | Represents |
|---|---|
| **Clinical** | Nurses (RN/LPN), Physicians, Radiology techs, Lab/Diagnostics techs |
| **Administration** | HR, Billing/Coding, Front Desk/Scheduling, Executive leadership |
| **IT** | Help desk/support techs, Systems admins, Network admins |
| **Facilities** | Maintenance, Janitorial, Security guards, Groundskeeping |

## Lab Environment / Tech Stack

| Component | Detail |
|---|---|
| Hypervisor | VirtualBox |
| Domain Controller OS | Windows Server 2022 (Desktop Experience) |
| Domain name | northwood.local (NetBIOS: NORTHWOOD) |
| DC hostname | NW-DC01 |
| Networking | Bridged Adapter (NW-DC01 connects directly to the physical home network) |

## Network Topology

| Setting | Value |
|---|---|
| Network mode | Bridged Adapter |
| Network range | 192.168.12.0/24 |
| Gateway | 192.168.12.1 |
| NW-DC01 static IP | 192.168.12.50 |
| NW-DC01 DNS | 192.168.12.50 (self) |

See [Phase 1: VM Setup](docs/phase1-vm-setup.md) for full configuration details and rationale.

## What Was Built

- [x] [Phase 1: VM Setup & Networking](docs/phase1-vm-setup.md)
- [x] [Phase 2: AD DS Promotion (northwood.local)](docs/phase2-adds-promotion.md)
- [ ] Phase 3: OU structure created (Clinical, Administration, IT, Facilities)
- [ ] Phase 4: Sample user accounts bulk-provisioned via PowerShell/CSV, security groups mapped to departments
- [ ] Phase 5: GPOs applied and scoped per OU
- [ ] Configuration and troubleshooting documented throughout

## Skills Demonstrated

- Active Directory Domain Services (AD DS) deployment and administration
- OU design and delegation
- PowerShell scripting (bulk user provisioning)
- Group Policy Object (GPO) creation and management
- Technical documentation

## Screenshots

Screenshots for each phase are stored in [`screenshots/`](screenshots/) and embedded in the phase docs.

| Phase | Highlights |
|---|---|
| 1 | VM configuration and network setup — see [Phase 1](docs/phase1-vm-setup.md) |
| 2 | AD DS role installed, `Get-ADDomain` verification, DNS SRV record check, NW-DC01 in Domain Controllers — see [Phase 2](docs/phase2-adds-promotion.md#screenshots) |

## Troubleshooting Log

Full details for each issue are documented in their respective phase docs. Summary so far:

| Phase | Issue | Fix |
|---|---|---|
| 1 | VirtualBox Network settings only showed NAT and Bridged Adapter — Internal Network option missing | VirtualBox 7.x hides advanced networking options behind an **Expert mode** toggle in the Settings window (Basic mode was active by default). Switched to Expert mode to reveal the full adapter list. |

| 2 | `Resolve-DnsName` prompted for `Name` instead of running | The name argument was lost when entering the command; reran it on one line with an explicit `-Name` parameter. |
| 2 | Host ↔ VM shared clipboard not working after installing Guest Additions | Unresolved. `VBoxService` and `VBoxTray` confirmed running and clipboard set to Bidirectional. Workaround: type commands manually and capture screenshots from the host. |

See [Phase 1: VM Setup](docs/phase1-vm-setup.md#troubleshooting) and [Phase 2: AD DS Promotion](docs/phase2-adds-promotion.md#troubleshooting-notes) for the full write-ups.