---
title:  "Serial Communication via Software"
date:   2024-02-16
categories: projects
---

Continuing from the last project ([7-segment display device driver](https://github.com/thinkty/n7d-lkm)), I wanted to expand the project to use hardware interrupts.
So, this project was aimed towards implementing a software approach to serial communication that is able to handle both transmission and receival (TX/RX).

There's a lot of overlap in the code for the transmission part, but in summary, instead of having a [workqueue](https://www.kernel.org/doc/html/next/core-api/workqueue.html) in the middle, the [hrtimer](https://docs.kernel.org/timers/hrtimers.html) directly takes out the bytes from the buffer and bitbangs it to the other end.
The same goes for the receiving side as the hrtimer that handles reading in the bytes just puts them directly into the buffer.
The main reason for the simplication of the code was probably due to the assumption that there will only be ONE instance of the hardware.
Therefore, a lot of race condition handling was removed. 

The software serial device driver is largely divided into two parts: TX (transmission) and RX (receival).
Each part is also divided into two parts: upper half and lower half.
The upper half is what the user interacts with.
It handles file operations like open, read, write, and close.
There's still some race condition handling as multiple users may write to the same device at the same time.
The lower half handles the interaction with the hardware.
It does bitbanging and it also handles reading in the bytes using hardware interrupts.
The fifos (linux/kfifo.h) provided by the kernal is used to not only store bytes from the user, but also connect the upper half and the lower half.

As the main focus of this project was on hardware interrupts, especially hardware interrupts on the Raspberry Pi, Device Tree was again needed to let the operating system know which pins to use and what kind of interrupts to expect.
Following are some useful resources to get started on how to use interrupts with Device Tree.

- [Broadcom BCM2835 GPIO (and pinmux) controller](https://www.kernel.org/doc/Documentation/devicetree/bindings/pinctrl/brcm,bcm2835-gpio.txt)
- [Common pinctrl bindings used by client devices](https://www.kernel.org/doc/Documentation/devicetree/bindings/pinctrl/pinctrl-bindings.txt)
- [How to specify gpio information for devices in device-tree](https://www.kernel.org/doc/Documentation/devicetree/bindings/gpio/gpio.txt)
- [Tutorial on Request IRQ](https://github.com/0xff07/linux-irq-modules)

For my use case, the device tree overlay has specified that an interrupt would listen on "falling-edges" on the specified GPIO pin (pin 17 by default).
As UART starts with a [start bit](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter#Start_bit) which goes from a logic high (1) to a low (0), this interrupt would be triggered on the start bits.
However, there may also be falling edges in the data bits as well.
Therefore, instead of just starting the hrtimer to handle the reading of the following data bits, it always checks if the hrtimer is active (i.e. waiting or executing hrtimer callback function).
If the hrtimer is active, it means that it is already handling the data bits and it is safe to ignore this particular falling edge interrupt.
I think it's quite an elegant method of handling incoming bits, but the results were not great.

After implementing the device driver, I tested with multiple baudrates to see how reliable it would be.
As someone who is not so familiar with hardware in general, based on what I've found online, bit error rates were the goto for testing serial communcation.
So, although this is not exactly comparing bit-by-bit, I went with byte-by-byte comparison.
The error rates are probably higher than the actual, but my main purpose was to compare between different baudrates.

<div class="table-container">
    <table>
        <thead>
            <tr>
            <th>Baudrate (bps)</th>
            <th>TX Bytes</th>
            <th>TX Error Bytes</th>
            <th>TX Error Rate</th>
            <th>RX Bytes</th>
            <th>RX Error Bytes</th>
            <th>RX Error Rate</th>
            </tr>
        </thead>
        <tbody>
            <tr>
            <td>9600</td>
            <td>23855</td>
            <td>0</td>
            <td>0 %</td>
            <td>27216</td>
            <td>0</td>
            <td>0 %</td>
            </tr>
            <tr>
            <td>19200</td>
            <td>19465</td>
            <td>1</td>
            <td>0.005137 %</td>
            <td>27180</td>
            <td>9</td>
            <td>0.033113 %</td>
            </tr>
            <tr>
            <td>38400</td>
            <td>35037</td>
            <td>171</td>
            <td>0.488055 %</td>
            <td>27918</td>
            <td>539</td>
            <td>1.930654 %</td>
            </tr>
            <tr>
            <td>57600</td>
            <td>29416</td>
            <td>76</td>
            <td>0.258363 %</td>
            <td>12642</td>
            <td>703</td>
            <td>5.560829 %</td>
            </tr>
            <tr>
            <td>112500</td>
            <td>29484</td>
            <td>3858</td>
            <td>13.085063 %</td>
            <td>3041</td>
            <td>1367</td>
            <td>44.952318 %</td>
            </tr>
        </tbody>
    </table>
</div>

![graph](/assets/images/2024-02-16-software_serial.svg)

The results were pretty disappointing and I think it's due to my poor implementation.
The absence of oversampling (as well as parity bits) may explain how RX is more unstable at higher baudrates than TX.
In addition, the bytes used in the tests were randomly generated which may be quite different from the usual use case.
On the positive side, at lower baudrates, it was quite stable and error-free.
Below is just a demo video just to show a functioning example.

<div class="iframe-container">
    <iframe class="iframe-body" src="https://www.youtube.com/embed/zff8Zb9E0xE" title="Software Serial Demo for Raspberry Pi" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

Overall, this was a great project to get a taste of interrupt handling, and seeing the bytes actually arrive and pop up on the terminal was very satisfying.
I think software approach may not be great for all use cases, but I liked how flexible it can be.
My code was probably was the issue, but it was a good experience nonetheless. 