# RootSeeker: Linux Privilege Escalation Auditor

RootSeeker is a lightweight script for studying security and finding developers in the Linux operating system. It automates intelligence (reconnaissance), takes intelligence out of control, which can lead to the seizure of power (root).

The script developed taking into account user capabilities: it works great on both plug-in distributions (Arch Linux, Fedora) and servomotors designed to work with PCs (CentOS 7, RHEL, Debian).

## Main features

#### RootSeeker checks the system in the following critical areas:
* System Recon: Collecting basic information (kernel, OS version, current user)
* Sensitive Files: Search for dangerous access rights to files /etc/shadow, /etc/passwd, etc
* SUID/SGID Binaries: Deep analysis of executable files with a SUID bit
* Integration with GTFOBins: The script highlights dangerous binaries and immediately provides a link to the way they are exploited
* Linux Capabilities: Checking for extended file permissions (Capabilities) that are often overlooked
* World-Writable Directories: Search for folders that are writable by any user (ideal for hiding the payload)
* Sudo & Permissions: Check sudo rights and search for accounts with empty passwords

## Screenshot:
<img width="552" height="974" alt="изображение" src="https://github.com/user-attachments/assets/b22afb07-6c62-4a64-afef-dd09c30ed0fd" />

## Installation
The script does not require the installation of dependencies and third-party interpreters. Only pure Bash.
```
git clone https://github.com/RomanLivik/root-seeker
cd root-seeker
chmod +x rootseeker.sh
```
#### Using:
```
./rootseeker.sh
```
## Why is this important?

In cybersecurity, "Privilege Escalation" is a critical stage of an attack. Administrators often leave SUID bits on standard utilities (for example, find or vim) for convenience, not realizing that this gives any user the opportunity to instantly become root.

RootSeeker helps you find these "holes" before an attacker does.

## Disclaimer

This tool is created exclusively for educational purposes and legal ethical hacking. The author is not responsible for any damage caused by the use of this script. Never use it on systems that you do not have written permission to audit.

## Contributing

Improvement ideas are welcome!
1. Split the fork of the project.
2. Create an app for new users (git checkout -b/AmazingFeature feature)
3. Make a commit (git commit -m 'Add some amazing features')
4. Make a push (git push origin feature/AmazingFeature)
5. Make an extraction request
