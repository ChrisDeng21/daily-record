# obmc-qemu-launch.sh

A helper script to run **OpenBMC QEMU virtual machines** for testing Aspeed-based BMC images (e.g., AST2700).  
This tool is intended for developers working with the **OpenBMC fork** or similar projects.

## Features

- Auto-detects your OpenBMC `bitbake` path
- Automatically locates the `image-bmc` binary inside your build tree
- Dynamically selects unused ports for:
  - SSH (default: 3222)
  - HTTPS (default: 3443)
  - IPMI (default: 3623)
- Locates the correct QEMU binary under `qemu-helper-native`
- Launches QEMU with correct machine settings for AST2700-based targets

## File Structure Assumptions

This script assumes the following build structure:

+ \<project-root\>/
  + bitbake
  + build/\<machine\>/tmp/deploy/images/\<machine\>/
    + image-bmc
  + meta-aspeed-sdk/
  + ...

## Requirements

- A working OpenBMC build environment
- An image has been built (e.g., via `bitbake obmc-phosphor-image`)
- QEMU helper binary exists (e.g., built via OpenBMC's qemu-native recipe)
- Bash 4.x or later
- Linux host with `ss` or `netstat` installed

## Usage

```bash
./obmc-qemu-launch.sh
```
