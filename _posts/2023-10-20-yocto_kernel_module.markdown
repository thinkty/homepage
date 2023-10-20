---
title:  "Testing Kernel Modules with Yocto"
date:   2023-10-20
categories: general
---

This semester, I've been working on implementing a Linux device driver for a [7-segment display](https://en.wikipedia.org/wiki/Seven-segment_display).
Using an Arduino to control such a display wouldn't be too difficult.
However, I wanted to implement a device driver for an actual operating system so that I would have some knowledge of how a kernel module works inside the kernel.
I think it's a good learning experience.

To get started on the development, along with my knowledge of operating systems from the previous course, I read through the [Linux Device Drivers](https://lwn.net/Kernel/LDD3/) to get the basics.
Although I heard that the book was outdated, I think it's a decent starting point since I got to understand what kind of environment the kernel modules operate in, which is quite different from a normal user process.
For example, I learned that you can't use the standard C libraries since they are implemented in user space, and the kernel libraries actually offer a lot of tools so that you don't need to implement everything from scratch, such as the [kfifo](https://elixir.bootlin.com/linux/latest/source/include/linux/kfifo.h) circular buffer.

After implementing some device driver code, it was now time to test it.
On my naive initial attempt, after checking that it compiled without errors, I ran it directly on my RaspberryPi which resulted in a catastrophe.
As soon as the module loaded, a kernel panic occurred, which I wasn't too surprised by.
After several reboots and what-nots, I soon realized I needed a better way to test the modules.

That's when I decided to use an emulator such as [QEMU](https://www.qemu.org/).
However, to run the emulator, we first need an *image* that the emulator can use to emulate.
One might just download an image off the web and run it, which would be fine, but I wanted to **automate** the process as much as possible, and I think it somehow resulted, just as in the [XKCD](https://xkcd.com/1319/) comics.

![image](https://imgs.xkcd.com/comics/automation.png)

After some struggle with [Buildroot](https://buildroot.org/) on the first attempt, I decided to give [Yocto](https://www.yoctoproject.org/) a try, and below is how I setup my debugging process.

## Initialization

After getting the initial setup done following the quick build [documentation](https://docs.yoctoproject.org/4.0.13/brief-yoctoprojectqs/index.html) for your Yocto version of interest (I went with Kirkstone), it is time to setup your own layer to incorporate an out-of-tree module into the image. Follow this [documentation](https://docs.yoctoproject.org/4.0.13/kernel-dev/common.html#getting-ready-for-traditional-kernel-development) up to step 4 to create and add your layer to the bitbake build environment.
After following the steps, there should be a new layer in the directory where your `poky` clone is at.

A good starting template for your out-of-tree module can be found [here](https://git.yoctoproject.org/poky/tree/meta-skeleton/recipes-kernel/hello-mod/hello-mod_0.1.bb), and you can follow this [documentation](https://docs.yoctoproject.org/4.0.13/kernel-dev/common.html#incorporating-out-of-tree-modules) to setup the out-of-tree module. 
Below is my recipe for the 7-segment device driver, and some of the additional points to look at would be the md5 checksum on the license, and a subtle update to `SRC_URI` to meet the requirements.
At the end of the recipe, we append the prefix `kernel-module-` before our recipe name since that is just how it is added by inheriting the `module` class. 

```
SUMMARY = "n7d-module"
DESCRIPTION = "Numerical 7-segment display device driver"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

inherit module

SRCBRANCH = "testing"
SRCREV = "${AUTOREV}" # Fetch the latest
SRC_URI = "git://github.com/thinkty/n7d-lkm.git;protocol=https;branch=${SRCBRANCH}"
S = "${WORKDIR}/git"

RPROVIDES_${PN} += "kernel-module-n7d"
```

After adding your recipe, we want to make sure that the module is added to the resulting image.
This can be done by adding `IMAGE_INSTALL:append = " <module_name>"` to your configuration (`conf/local.conf`), which will execute the `install_modules` in your kernel module Makefile so your device is visible in the kernel. 
As seen in my recipe, I fetch the source from Github from the `testing` branch.
So, I will need to commit and push any testing changes before I build the image.

## Debugging

Once the setup is done, the debugging process isn't too bad.
To make sure that `bitbake` is available, run `source oe-init-build-env <name>`.
Then, in my case, running `bitbake core-image-minimal` will build the minimal cmd-line image for QEMU which I can run with `runqemu nographic` to test my module.

Compared to other debugging processes, I think this is quite suitable for now.
Later on, I plan to also use Yocto to build the final RaspberryPi image with my device driver installed to run it on the actual machine instead of the emulator.
