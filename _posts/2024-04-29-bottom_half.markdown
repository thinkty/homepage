---
title:  "Linux Bottom Half"
date:   2024-04-29
categories: general
---

> The information in this post may not be up-to-date, and it is primarily for my learning purposes.
Please feel free to email me with any incorrect information.

Recently, I started working on a project: a Linux device driver for a GPS receiver.
The project is built on [software-serial](https://github.com/thinkty/software-serial) which is a UART device driver implementation using only software and raw GPIO.
In software-serial, I only implemented the *top half* of interrupt handling.
Top half refers to the interrupt service routine (or the interrupt handler), like the one that I defined to handle falling edge events on the specified GPIO pin.

## Top Half

The characteristic about the top half is that, according to the Linux Kernel Development (3rd) book, it at least runs with the interrupts of the same level disabled and at most runs with all the interrupts disabled on the same processor.
With interrupts disabled, if the top half is not handled in a timely manner, it can result in interrupts being missed.
For example, if network RX interrupts are disabled, new packets arriving may just be dropped.
A packet loss in TCP critically penalizes the performance.

Back to software-serial, when a new falling edge is detected, an interrupt is raised, and it is handled by starting (if it wasn't already started) a timer.
After the timer expires, the callback function then reads the bit and eventually forms a byte that would then be added into the kfifo buffer.
There isn't any processing to be done after storing the byte.

However, in this GPS receiver project, the received bytes form an [NMEA](https://en.wikipedia.org/wiki/NMEA_0183) message that needs to be parsed.
This is very similar to the tcp/ip stack, where raw data from the IP packets eventually forms the TCP segment, and it is then processed to handle TCP related mechanisms.
Since there is a top half, one can easily assume that there is also a bottom half.
> As a sidenote, top half and bottom half are different from the terms upper half and lower half.

## Bottom Half

So, what does the bottom half do, and why is the bottom half needed?
*Bottom half*, or *BH*, used to be a specific mechanism in the early days of Linux.
Later on, some people used the bottom half interchangeably with *softirqs* and *tasklets*, which was built on softirqs.
There are several points throughout the kernel where softirqs are handled.
For example, right after handling the hardware interrupt, the kernel checks if there are any pending softirqs.
The check is placed since hardware interrupts usually raise software interrupts to handle more time consuming work.
However, there is a deeper problem with this approach, which I will briefly mention later.

Nowadays, some people just use the term *deferred work* to refer to the mechanisms used for implementing the bottom half, including but not limited to *softirqs* and *tasklets*.
In the LKD book, the bottom half is just a generic operating system term that refers to the deferred portion of interrupt processing.

So, we know that the top half and bottom half exist, but a question remains: what should be done in the top half and the bottom half?
According to the LKD book, there are some tips to determine:
- Time-sensitive work should be done in the top half
- Hardware-related work should be done in the top half
- Work that requires no other interrupts to preempt it should be done in the top half
- Everything else should be done in the bottom half

So, according to the tips, processing the NMEA messages seems like a job for the bottom half.

In Linux, there are several mechanisms to implement the bottom half (or deferred work): threaded interrupt handlers (threadedirq), workqueues, softirqs, and tasklets.
Although there are 4 options, according to the LWN articles<sup>[1](https://lwn.net/Articles/925540/), [2](https://lwn.net/Articles/960041/)</sup>, the general consensus is that softirqs and tasklets (that are built on top of softirqs) are not recommended as they are planned to be deprecated.

As mentioned before, softirqs are handled at various points throughout the kernel, and they are processed in interrupt context.
Although it can still be interrupted by actual hardware interrupts, it is still an interrupt context where user processes are blocked.
This can lead to a problem where too many softirqs may starve other processes.
To avoid starvation, there are two heuristics put in place:
- A maximum of 10 softirqs can be handled at once
- Softirqs can be handled at a maximum of 2 milliseconds

When one of the limits is met, the softirq is handled in a kernel thread called *softirqd/#* which runs with the same priority as other processes and runs in process context.
Some people pointed out that such heuristics are [*disgusting*](https://lwn.net/Articles/940497/) and are actively trying to replace the use of softirqs and tasklets with other mechanisms.
There is also a problem of use-after-free with tasklets briefly mentioned in the [mailing list](https://lore.kernel.org/lkml/ZcACvVz83QFuSLR6@slm.duckdns.org/T/), so a special workqueue to replace tasklets was introduced recently. 
So, I think softirqs and tasklets will be deprecated at some point in the future.

> As a sidenote, kernel timers (including the hrtimer) are also deferring work.
However, unlike the conventional bottom half that defers work to be done at **any** time in the future, timers do the work after a **specific** time in the future.
Thus, it is not included above. 

## Workqueue

Workqueues are different from softirq or tasklets in a way that the work itself runs in process context as it uses the kernel threads (*kworker/#*) to actually execute the work functions.
Being in process context means that it can block (sleep).
However, as it is a process context thread, it has the overhead of context switching, as mentioned in the [video](https://www.youtube.com/watch?v=rmv40f5K8AI) on deferred work.
The work can be queued on the shared workqueue and executed on the shared thread (ex. `kworker/0:1-events` which can be seen using the command `ps ax | grep kworker`).
New workqueues and a set of threads can be allocated dynamically during runtime as well.
The creation of new workqueues is available, as some works may take too long to execute and eventually impact other works in the shared queue.

The terminology may be confusing due to so many instances of the word "work," but according to the [documentation](https://docs.kernel.org/next/core-api/workqueue.html), here is my understanding.
The workqueues are just a data structure holding a linked list of works that are just pointers to functions.
The worker threads (*kworker*) are the actual threads that execute the work functions.
Work-pools manage the worker threads as drivers or other subsystems may add new workqueues and corresponding worker threads.
So, once a work is initialized and enqueued to a workqueue, a worker-pool is assigned according to the workqueue [attributes](https://docs.kernel.org/next/core-api/workqueue.html#flags).

> There are also workqueues that utilize the BH (softirq) mechanism to replace tasklets, and those works are executed in interrupt context.
The patch is quite recent, and I think it's a middle step into cleaning up tasklets and possibly softirqs from the kernel. There is also a rescue worker, but I have no idea what it does just based on the documentation.

## New Workqueue

In recent versions of workqueue, there can now be multiple execution contexts in the same workqueue.
Don't let the keyword context confuse you.
In my understanding, based on the scenarios shown in the document, works don't necessarily wait for another work to finish sleeping if the `max_active` parameter is greater than 1.
I highly recommend going through the [examples](https://docs.kernel.org/next/core-api/workqueue.html#example-execution-scenarios) in the document and noticing how the work immediately starts after the previous work went to sleep.
Again, I did not understand how the example scenario works when the `WQ_CPU_INTENSIVE` flag is set.
There are more details with regards to performance tuning in the documentation.
Although I am unable to fully comprehend at my current level, I'm leaving a note here for my future self.

## Re-entrancy

To end the discussion on workqueue, I want to briefly leave a note on re-entrancy.
In the context of the kernel, re-entrancy means that the function is called again before it completes its previous execution.

Since softirqs were meant for processing lots of data quickly, they are re-entrant.
However, tasklets and workqueues are usually guaranteed to be **NOT** re-entrant.
Tasklets are never executed on two or more processors at once.
The same is said for work functions.
As long as the workqueue is used as [intended](https://docs.kernel.org/next/core-api/workqueue.html#non-reentrance-conditions), workqueue guarantees that only 1 kernel thread will be executing the work function, even if it is a self-queueing work.

However, being re-entrant or not, the shared resources within the bottom half must be properly locked or handled in a way to avoid race conditions, as the resource may still be accessed elsewhere while the function itself isn't.

## Threaded Interrupts

Although I mentioned threadedirq above, I didn't really explain about it as, I did not find sufficient information about it.
As far as I know, threadedirq seems to implement not just the bottom balf but also the top half.
According to the latest [syntax](https://docs.kernel.org/core-api/genericirq.html#c.request_threaded_irq), the `handler` is used to acknowledge the hardware interrupt and runs in hardware context, while the `thread_fn` runs in kernel threads just like workqueues.
After an interrupt is received, the kernel threads will be woken up to handle the interrupt.

This is a way of not only moving away from the usage of softirqs, but it also introduces simplicity, in my opinion.
An article about threaded interrupt handlers can be found [here](https://lwn.net/Articles/302043/).

## Which should I use?

So, which bottom half mechanism should I use?
The overall option seems to be workqueues.
Although the processing of NMEA messages is not time-sensitive, it should be done quickly enough that the kfifo buffer isn't overwritten with new bytes.

Will work inside the workqueue be handled fast enough such that we don't lose any NMEA messages?
Since I am no wizard or have much experience with kernel development, I must go through trial and error.
A good starting point may be a decent-sized fifo buffer with a shared workqueue to process the bytes.
By using the return value from [`schedule_work`](https://elixir.bootlin.com/linux/v6.1/A/ident/schedule_work), I can know if the work isn't fast enough compared to incoming new messages.

If messages are dropped from time to time, I may need to decide whether having some messages lost is fine.
There are also other factors that impact performance.
If there are other work functions constantly hogging the worker threads, allocating a new workqueue may be necessary.
