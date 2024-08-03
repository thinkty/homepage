---
title:  "Programming STM32 Using VSCode on Linux"
date:   2024-08-03
categories: general
---

Although there is the [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html), some prefer not to be locked into a specific IDE.
So, I wanted to write a post on how to setup VSCode on Linux to program STM32s.
(Does this mean I'm now locked into VSCode?)

I referred to the following guides to create this post:

- [Erich Styger's post on VSCode setup](https://mcuoneclipse.com/2021/05/01/visual-studio-code-for-c-c-with-arm-cortex-m-part-1/)
- [Newkular's post on Cortex Debug setup for ST-LINK](https://forum.electro-smith.com/t/st-link-and-cortex-debugger-on-ubuntu-24-04/5260)

# Pre-Installation

First, install [VSCode](https://code.visualstudio.com/download) to get started.
In addition to VSCode, some packages must be installed in order to utilize the tools and extensions later on.

- Make
- CMake
- libusb-1.0-0-dev 
- libtinfo5
- libncurses5 & libncursesw5

the following tools must be installed as well:

- [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- [OpenOCD from STM](https://github.com/STMicroelectronics/OpenOCD)

The ARM GNU Toolchain provides the cross-compiler for ARM and handles building the binary, which will be flashed onto the MCU.
It has support for a wide variety of ARM architectures, so it's not limited to just STM products.
One thing to note is that GDB in version 13.2.Rel1 uses Python 3.8.
Try opening the GDB server, and if you encounter an error, I recommend following [this](https://stackoverflow.com/a/77456816) answer from StackOverflow.

OpenOCD has its own mainstream branch as well, but this repository from STM is what is used in the STM32CubeIDE to program and debug STM32s.
To install OpenOCD, run the following commands in the downloaded directory:

```
./bootstrap
```
```
./configure
```
```
make
```
```
sudo make install
```

Once the external tools have been installed, we now need to configure the USB rules so that we have permission to read and write to the MCU connected via USB.
The necessary files are [STSW-LINK007](https://www.st.com/en/development-tools/stsw-link007.html).
After downloading and extracting the files, follow the instructions in the `readme.txt` to add the USB rules for ST-Link devices.
Once complete, the added rules for [udev](https://unix.stackexchange.com/questions/550037/how-does-udev-uevent-work) must appear in `/etc/udev/rules.d`.
Run the following command to reload the rules.

```
sudo udevadm control --reload-rules
```

If you look at one of the newly added udev rules, you may notice that the permission mode is set to 660.
This means that others (i.e., those not in the group `plugdev`) do not have permission to read and write to the devices.
If your user is not in the group `plugdev`, please add it.

Just to make sure everything has been setup properly, we can run the command below to connect to the MCU.
Depending on your MCU, change the `target/stm32f3x.cfg` accordingly.
The configuration files are in `/usr/local/share/openocd/scripts/target` by default.
Check the directory to see if your MCU is supported.

```
openocd -s /usr/local/share/openocd/scripts -f interface/stlink.cfg -f target/stm32f3x.cfg
```

Once the device rules and OpenOCD has been installed properly, you should be able to see the following output:

```
Info : Listening on port 3333 for gdb connections
```

This means that you can now attach GDB to your localhost's port 3333 to debug remotely.
Since we don't have an image to flash nor any code to compile, let's move on to generating the template code.

# Code Generation

Although you can start from scratch, you can also utilize the code generation offered by [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html).
The output may not be pretty, but it really does help tremendously with hardware initialization.
Using the graphical interface, you can configure the clock rates and peripherals.
Then, the tool will generate template code to initialize the hardware so that you can start writing application code.

First, select the target MCU or board to generate the code for.
I only have the Nucleo boards, so I usually enter the board name and select the board.
Then, set the peripherals in the *Pinout & Configuration* tab, and clock-related settings under *Clock Configuration*.

In the *Project Manager* tab, you can set the name for your project (which will eventually be the name of the output binary) and more.
To use the generated code with the VSCode extensions, make sure to select the *Toolchain / IDE* under *Project* as `CMake`.
Freely modify other settings to match your preference, and click *Generate Code* when ready.

From the generated files, there are a couple of things to modify in order to use it with the installed toolchain.
First, the default `cmake/gcc-arm-none-eabi.cmake` has the following line:

```
set(TOOLCHAIN_PREFIX                arm-none-eabi-)
```

Update the `TOOLCHAIN_PREFIX` so that it points to the ARM GNU Toolchain we installed earlier.

Next, in the `CMakePreset.json` file, update the `configurePresets.generator` to `Unix Makefiles` if you want to use Make instead of Ninja for the build system.

Now that the files have been appropriately modified to be used with the extensions, let's move on to installing and using the VSCode extensions.

# VSCode Extensions

The VSCode extensions to install are as follows:

- [Cortex Debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug) : Debugging via VSCode.
- [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack) : CMake extension to build profiles and binaries.
- [LinkerScript](https://marketplace.visualstudio.com/items?itemName=ZixuanWang.linkerscript) : Linker script syntax highlighting.
- [ARM Assembly](https://marketplace.visualstudio.com/items?itemName=dan-c-underwood.arm) : Assembly (ARM) syntax highlighting.

Once the extensions have been installed, configurations are required for the extensions to work with the target.
Create a `.vscode` directory to store all the VSCode extension-specific configurations.

To start with, in order to debug with VSCode (using the Cortex Debug extension), we need a `launch.json` file.
Create `launch.json` inside `.vscode` and fill it with the following texts:

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "cwd": "${workspaceRoot}",
            "executable": "./build/Debug/f303re.elf",
            "name": "Debug (OpenOCD)",
            "request": "launch",
            "type": "cortex-debug",
            "servertype": "openocd",
            "configFiles": [
                "/usr/local/share/openocd/scripts/interface/stlink.cfg",
                "/usr/local/share/openocd/scripts/target/stm32f3x.cfg"
            ],
            "searchDir": [],
            "runToEntryPoint": "main",
            "showDevDebugOutput": "raw"
        }
    ]
}
```

You can also use the *Add Configuration...* button on the bottom right to add new launch configurations.
For more information on configurations, refer to the [manual](https://code.visualstudio.com/docs/cpp/launch-json-reference).
As mentioned above, make sure you have correctly set the executable path and configuration file paths.

Optionally, you can also provide an SVD (System View Description) file to get hardware register information for the peripherals.
The SVD files are usually provided by the manufacturer or can be found in [some](https://github.com/tinygo-org/stm32-svd) Github repositories on the net.

Now that the extensions have been configured, we can now run and debug.
If you've used VSCode before, you probably know how it is done.
If not, it's not easy to explain in words, so I'll leave a [link](https://code.visualstudio.com/docs/editor/debugging) to the official guide.

The code used in this post is on [Github](https://github.com/thinkty/f303re-template).
