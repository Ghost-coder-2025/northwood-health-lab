# Phase 1 — VM Setup

## 1. Download ISO
Downloaded the Windows Server 2022 Evaluation ISO.

## 2. Create a New VM in VirtualBox
**Hardware**
- CPU/Processors: 2
- Base Memory/RAM: 4096 MB
- Disk Size: 60 GB

**Name of the server:** NW-DC01

## 3. Microsoft Server Operating System Setup
Options presented during install:
1. Windows Server 2022 Evaluation
2. Windows Server 2022 Standard Evaluation (Desktop Experience)
3. Windows Server 2022 Datacenter Evaluation
4. Windows Server 2022 Datacenter Evaluation (Desktop Experience)

**Selected:** Option 2 — Standard Evaluation (Desktop Experience)
**Why:** Standard edition covers everything needed for AD DS/GPO work (Datacenter's extra features — unlimited VM licensing, Storage Spaces Direct, Shielded VMs — are for large-scale virtualization hosts, not relevant here). Desktop Experience keeps the GUI available for tools like AD Users and Computers and Group Policy Management while learning.

## 4. Installation Type
1. Upgrade: Install Microsoft Server OS and keep files, settings, and apps
2. Custom: Install Microsoft Server OS only

**Selected:** Custom
**Why:** Fresh VM with no existing OS to upgrade.

## 5. Disk Partitioning
Selected the unallocated 60 GB disk and let Windows Setup auto-create the required partitions (no manual partitioning needed for this lab).

## 6. Customize Settings
Set the local Administrator password for the server.

## 7. Sign-In
1. Landed on a screen reading "Press Ctrl+Alt+Del to unlock."
2. Physical Ctrl+Alt+Del is captured by the host OS, not passed to the VM — bypassed via VirtualBox menu: **Input → Keyboard → Insert Ctrl-Alt-Del**.
3. Entered the password, landed in Server Manager.

## 8. Rename Server
Renamed the machine to **NW-DC01** via Server Manager → Local Server → Computer Name.

## 9. Network Adapter Setup (VirtualBox)
1. Selected **Bridged Adapter** — this places the VM directly on the physical home network with its own real, routable IP, rather than behind a NAT translation layer. This more closely mirrors how a production domain controller's network adapter is actually configured (a real, direct IP on a routable network segment).
2. In VirtualBox Manager, right-click the VM → **Settings**.
3. Go to **Network**, switch to **Expert** mode (see Troubleshooting below).
4. **Adapter 1** → Attached to: **Bridged Adapter**.
5. **Name** dropdown → selected host machine's active connection (e.g. Intel(R) Wi-Fi 6E).
6. **Promiscuous Mode** → set to **Deny** (VM only sees its own traffic — no need to see other network traffic for this lab).
7. Clicked OK.

## 10. Network Setup (Inside Windows Server)
Since the VM uses Bridged Adapter (directly on the home network), NW-DC01 must follow the same IP addressing scheme as the rest of the network.

1. Ran `ipconfig` on the host desktop to determine the network range:
   - Host IPv4: 192.168.12.186
   - Default Gateway: 192.168.12.1
   - Network range: 192.168.12.0/24
2. Set a static IP on NW-DC01 via **Network Connections → adapter Properties → Internet Protocol Version 4 (TCP/IPv4)**:

   | Setting | Value |
   |---|---|
   | IP Address | 192.168.12.50 |
   | Subnet Mask | 255.255.255.0 |
   | Default Gateway | 192.168.12.1 |
   | Preferred DNS Server | 192.168.12.50 (self) |

   **Why a static IP:** A domain controller must be reachable at a consistent, predictable address. If NW-DC01 used DHCP, its IP could change after a reboot or lease renewal, breaking authentication, DNS resolution, and GPO delivery for any client relying on it.

   **Why DNS points to itself:** Active Directory Domain Services depends on DNS being resolvable by the DC during and after promotion. Pointing NW-DC01's DNS setting to its own IP satisfies this requirement.

3. Verified connectivity: `ping 192.168.12.1` (gateway) — 4 sent, 4 received, 0% loss.

---

## Troubleshooting

### Issue: VirtualBox Network settings only showed NAT and Bridged Adapter
**Symptom:** Attempting to configure Internal Network + NAT for network isolation, the "Attached to" dropdown only listed NAT and Bridged Adapter — no Internal Network option visible.
**What I checked:** Confirmed VirtualBox version (7.1.8), searched for a separate Network Manager tool, tried multiple menu paths.
**Root cause:** VirtualBox 7.x hides advanced networking options (Internal Network, Host-only Adapter, NAT Network, Generic Driver) behind an **Expert mode** toggle in the VM Settings window. The default **Basic mode** only exposes NAT and Bridged Adapter.
**Fix:** Switched the Settings window from Basic to Expert mode, revealing the full adapter list.
**Decision:** Proceeded with Bridged Adapter instead of Internal Network + NAT. Simpler to configure with only one adapter needed, and arguably a closer match to how a real production DC's network adapter is configured — a direct, routable IP rather than an isolated/translated one.
**Lesson:** Check for hidden or collapsed option toggles (Basic/Expert, Simple/Advanced, etc.) before assuming a UI is missing a feature.