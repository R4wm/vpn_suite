# Windows VPN Guide

This guide is for a Windows user who has already been given a WireGuard VPN config file.

You do not need to edit the file. You only need to install the app, import the file, and turn the VPN on.

## What You Should Have
- A Windows computer with internet access
- Your VPN config file ending in `.conf`
- Permission from the VPN owner to connect

## 1. Install WireGuard
1. Open a web browser.
2. Go to `https://www.wireguard.com/install/`
3. Download `WireGuard Installer for Windows`.
4. Run the installer.
5. If Windows asks for permission, click `Yes`.

## 2. Import Your VPN File
1. Open the `WireGuard` app.
2. Click `Import tunnel(s) from file`.
3. Select the VPN `.conf` file you were given.
4. A new tunnel will appear in the app.

If the app shows the tunnel details, do not change anything unless the VPN owner told you to.

## 3. Connect
1. In the WireGuard app, click `Activate`.
2. Wait a few seconds.
3. The status should show that the tunnel is active.

## 4. Check That It Worked
Use either of these simple checks:

### Option A: Basic check
1. Open a web browser.
2. Visit a site or service that only works when connected to the VPN.

### Option B: Ping check
1. Open `PowerShell`.
2. Run:

```powershell
ping 10.8.0.1
```

If the VPN is working, you should get replies instead of a timeout.

## 5. Disconnect
1. Open the `WireGuard` app.
2. Click `Deactivate`.

## Common Problems

### The file will not import
- Make sure the file ends in `.conf`.
- Try saving the file to `Downloads` or `Desktop` first, then import it again.
- Ask the VPN owner to send a fresh copy if the file looks damaged or incomplete.

### It imports, but will not connect
- Make sure your internet is working before you turn on the VPN.
- Wait 10 to 15 seconds after clicking `Activate`.
- Turn the tunnel off, then on again.
- Restart WireGuard and try again.

### It says connected, but the thing you need still does not work
- The VPN may be limited to certain network destinations only.
- Ask the VPN owner what address, website, or shared resource you should test.

## When To Ask For Help
Send these details to the VPN owner:
- Whether WireGuard installed successfully
- Whether the tunnel imported successfully
- Whether `Activate` worked
- The result of `ping 10.8.0.1`
- Any error message shown by WireGuard

## For The VPN Owner
This guide assumes the user received a ready-to-import config file with the correct `Endpoint` already set.
