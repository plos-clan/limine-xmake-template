# Limine C Xmake Template

This repository contains a basic x86-64 kernel in C using Limine.

Only UEFI is supported, because BIOS related files are not included.

### Dependencies

Xmake is required to build this project.

No need to install cross-compilers, as your system's GCC is usually enough (x86_64 platform).

### Xmake targets

Running `xmake` will build the kernel and create a bootable ISO image.

Running `xmake run` will build above automatically and run it in QEMU.
