# macOS VPN Setup Guide

This guide is for someone who has already been given a ready-to-use WireGuard VPN file.

You do not need to edit anything in the file. Just install the app, import the file, connect, and test it.

## What You Need
- A Mac with internet access
- Your VPN file ending in `.conf`
- The name of one thing you should test after connecting
- This guide

## Before You Start
1. Save the `.conf` file somewhere easy to find, such as `Downloads` or your Desktop.
2. Make sure your internet is working before you turn the VPN on.
3. Close the file if it opens in a text editor. Do not change it.

## 1. Install the WireGuard App
1. Open the `App Store`.
2. Search for `WireGuard`.
3. Install the app named `WireGuard`.
4. Open the app after it finishes installing.

If macOS asks for permission related to VPNs or network changes, allow it.

## 2. Import Your VPN File
1. In the `WireGuard` app, click `Import tunnel(s) from file`.
2. Browse to the `.conf` file you were given.
3. Select the file and click `Import`.
4. A new tunnel should appear in the app.

If WireGuard shows the tunnel details, leave them as they are unless the VPN owner specifically told you to change something.

## 3. Connect to the VPN
1. In the `WireGuard` app, turn the tunnel `On`.
2. Wait 10 to 15 seconds.
3. Confirm the tunnel shows as active.

The first time you connect, macOS may ask you to approve adding a VPN configuration. Approve it and, if prompted, enter your Mac password.

## 4. Test That It Worked
Use the simple check first. If you were also given a company site, shared drive, printer, camera system, or other internal resource to test, try that too.

### Simple Test
1. Open `Terminal`.
2. Copy and run this command:

```bash
ping -c 4 10.8.0.1
```

3. Wait for the result.

If it worked, you should see lines that include `64 bytes from 10.8.0.1` or similar replies. If it did not work, you will usually see timeouts or no replies.

### Real-World Test
1. Open the app, website, folder, or system you were told to test.
2. Confirm it works while the VPN is active.

## 5. Disconnect When You Are Done
1. Open the `WireGuard` app.
2. Turn the tunnel `Off`.

## Common Problems

### The file will not import
- Make sure the file name ends in `.conf`.
- Move the file to `Downloads` or `Desktop` and try again.
- Ask for a fresh copy if the file seems damaged or incomplete.

### The app installed, but the VPN will not turn on
- Check that your normal internet connection is working first.
- Wait a full 15 seconds after turning it on.
- Turn the tunnel off, then on again.
- Close WireGuard and open it again.
- Restart the Mac and try one more time.

### macOS asks for permission and the VPN still does not work
- Open `System Settings`.
- Go to `Privacy & Security` and make sure WireGuard is allowed if macOS shows a blocked or pending permission.
- Try connecting again.

### The VPN says it is active, but the thing you need still does not work
- Try the `ping -c 4 10.8.0.1` test again.
- The VPN may only allow access to certain systems.
- Confirm which website, folder, or device you were supposed to test.

## What To Send If You Need Help
Send these details to the VPN owner:
- Whether WireGuard installed successfully
- Whether the `.conf` file imported successfully
- Whether the tunnel showed as active
- The result of `ping -c 4 10.8.0.1`
- A screenshot of any error message
