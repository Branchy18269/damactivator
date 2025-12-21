# DamActivator

**A modern, clean, and open-source Windows Activation Tool.**

> **Disclaimer:** This tool uses Key Management Service (KMS) keys provided by Microsoft for evaluation and testing purposes. It is intended for educational use and system administration testing. Please support Microsoft by purchasing genuine licenses for production environments.

---

## 🚀 Features

* **Comprehensive Support:** Activates essentially every version of Windows available:
    * **Consumer:** Windows 10/11 (Home, Pro, Single Language).
    * **Enterprise:** Enterprise, Education, LTSC, IoT, and Pro for Workstations.
    * **Server:** Complete range from Server 2008 to the new Server 2025 (Standard, Datacenter, Azure, Essentials, Multipoint).
    * **Legacy:** Windows 7, 8, 8.1, and Vista.
* **Modern GUI:** A custom-built, dark-themed user interface.
* **Rich Navigation:** Easy-to-use grid layouts for selecting generations and editions.
* **Real-Time Logging:** Watch the activation process live (Registry cleaning, Key installation, KMS handshake).
* **Fail-Safe Design:** Includes "Return Home" functionality and error handling.
* **Standalone Executable:** No installation required—just run and go.

## 📥 Installation

1.  **Download the Release:**
    Go to the **[Releases](../../releases)** page and download the latest version.

2.  **Download the Files:**
    * `DamActivator.exe`

## ⚡ Usage

1.  **Double-click** `DamActivator.exe`.
2.  **Accept Administrator Prompt:** The tool requires Admin privileges to install keys and manage the licensing service.
3.  **Select Your Edition:** Navigate the menus to find your specific Windows version.
4.  **Activate:** Click the button for your edition and wait for the success screen!

## 🛠️ Troubleshooting

### Windows Defender / Antivirus Warning?
Because this program modifies system activation files (and was converted from a PowerShell script), Windows Defender may flag it as "Unknown" or a "HackTool".
* **Solution:** You may need to create an exception for the folder or temporarily disable real-time protection to run the tool.
* **Open Source:** If you are uncomfortable running the `.exe`, you can download the source code (`DamActivator.ps1`) and run it manually via PowerShell.

### Activation Failed?
* **Check Internet:** A live internet connection is required to reach the KMS servers.
* **Server Busy:** Sometimes the public KMS servers are overloaded. Wait a few minutes and try again.
* **Firewall:** Ensure your firewall isn't blocking `cscript.exe` or outbound connections on port 1688.

### "Success" Windows is now Activated

## 📝 Credits

* **Developer:** [Branchy18269](https://github.com/Branchy18269) (Will Hyndman)
* **Contact:** contact@damvan.ca
* **Website:** [damvan.ca](https://damvan.ca)
* **KMS Services:** Provided by `msguides.com`

---
*Created with ❤️ in Nova Scotia, Canada.*
