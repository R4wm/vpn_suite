# Windows VPN Setup Guide

This guide is for someone who has already been given a ready-to-use WireGuard VPN file.

You do not need to edit anything in the file. Just install the app, import the file, connect, and test it.

## What You Need
- A Windows computer with internet access
- Your VPN file ending in `.conf`
- The name of one thing you should test after connecting
- This guide

## Before You Start
1. Save the `.conf` file somewhere easy to find, such as `Downloads` or `Desktop`.
2. Make sure your internet is working before you turn the VPN on.
3. Close the file if it opens in Notepad or another app. Do not change it.

## 1. Install the WireGuard App
1. Open your web browser.
2. Go to `https://www.wireguard.com/install/`.
3. Under Windows, download `WireGuard Installer`.
4. Open the installer you downloaded.
5. If Windows asks whether to allow the app to make changes, click `Yes`.
6. Follow the install steps until it finishes.

## 2. Import Your VPN File
1. Open the `WireGuard` app.
2. Click `Import tunnel(s) from file`.
3. Browse to the `.conf` file you were given.
4. Select the file and click `Open`.
5. A new tunnel should appear in the WireGuard window.

If WireGuard shows the tunnel details, leave them as they are unless the VPN owner specifically told you to change something.

## 3. Connect to the VPN
1. In the `WireGuard` app, click `Activate`.
2. Wait 10 to 15 seconds.
3. Look for the tunnel status to show as active.

Windows may ask for permission related to a VPN or network connection. If it does, allow it.

## 4. Test That It Worked
Use the simple check first. If you were also given a company site, shared drive, printer, camera system, or other internal resource to test, try that too.

### Simple Test
1. Open `PowerShell`.
2. Copy and run this command:

```powershell
ping 10.8.0.1
```

3. Wait for the result.

If it worked, you should see replies. If it did not work, you will usually see `Request timed out`.

### Real-World Test
1. Open the app, website, folder, or system you were told to test.
2. Confirm it works while the VPN is active.

## 5. Disconnect When You Are Done
1. Open the `WireGuard` app.
2. Click `Deactivate`.

## Common Problems

### The file will not import
- Make sure the file name ends in `.conf`.
- Move the file to `Desktop` or `Downloads` and try again.
- Ask for a fresh copy if the file seems damaged or incomplete.

### The app installed, but the VPN will not turn on
- Check that your normal internet connection is working first.
- Wait a full 15 seconds after clicking `Activate`.
- Click `Deactivate`, then `Activate` again.
- Close WireGuard and open it again.
- Restart the computer and try one more time.

### The VPN says it is active, but the thing you need still does not work
- Try the `ping 10.8.0.1` test again.
- The VPN may only allow access to certain systems.
- Confirm which website, folder, or device you were supposed to test.

## What To Send If You Need Help
Send these details to the VPN owner:
- Whether WireGuard installed successfully
- Whether the `.conf` file imported successfully
- Whether the tunnel showed as active
- The result of `ping 10.8.0.1`
- A screenshot of any error message
