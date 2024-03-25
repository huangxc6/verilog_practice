# Clock Domain Crossing(CDC)

## 1. Metastability

Metastability refers to signals that do not assume stable 0 or 1 states for some duration of time at some point during normal operation of a design.   

![Metastable](D:\BaiduSyncdisk\code practice\verilog_practice\CDC\images\Metastable.png)



## 2. Synchronizers

### 2.1 Two synchronization scenarios

(1) It is permitted to miss samples that are passed between clock domains.

(2) Every signal passed between clock domains must be sampled.First scenario: sometimes it is not necessary to sample every value, but it is important that the sampled values are accurate. One example is the set of gray code counters used in a standard asynchronous FIFO design. In a properly designed asynchronous FIFO model, synchronized gray code counters do not need to capture every legal value from the opposite clock domain, but it is critical that sampled values be accurate to recognize when full and empty conditions have occurred.Second scenario: a CDC signal must be properly recognized or recognized and acknowledged before a change is permitted on the CDC signal.

### 2.2 Two flip-flop synchronizer

![two flip-flop sync](D:\BaiduSyncdisk\code practice\verilog_practice\CDC\images\two flip-flop sync.png)

### 2.3 MTBF - mean time before failure

rger numbers are preferred over smaller numbers. Larger MTBF numbers indicate longer periods of time between potential failures, while smaller MTBF

SNUG Boston 2008 Clock Domain Crossing (CDC) Design & VerificationRev 1.0 Techniques Using SystemVerilog10numbers indicate that metastability could happen frequently, similarly causing failures within the design.

![mtbf](D:\BaiduSyncdisk\code practice\verilog_practice\CDC\images\mtbf.png)

### 2.4 Three flip-flop synchronizer

in very high speed designs

### 2.5 Synchronizing signals from the sending clock domain

**Frequently asked question regarding CDC design**: Is it a good idea to register signals from the sending clock domain before passing the signals to the receiving clock domain?   

**registering signals in the sending clock domain should generally be required**  

![2.5 unregistered](D:\BaiduSyncdisk\code practice\verilog_practice\CDC\images\2.5 unregistered.png)

### 2.6 Synchronizing signals into the receiving clock domain

Signals in the sending clock domain should be synchronized before being passed to a CDC boundary.  

![2.6 registered](D:\BaiduSyncdisk\code practice\verilog_practice\CDC\images\2.6 registered.png)

# 3.0 Synchronizing fast signals into slow domains

When missed samples are not allowed, there are two general approaches to the problem:

(1) An open-loop solution to ensure that signals are captured without acknowledgment.

(2) A closed-loop solution that requires acknowledgement of receipt of the signal that crosses a CDC boundary

