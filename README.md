# verilog-seq-fulladder-modular-tb
This repo has the RTL code for a full adder implemented implemented sequentially using two half adders and an or gate. To go along with it, is a modular self-checking SystemVerilog testbench implemented with a generator, driver, monitor, and scoreboard.

This mini-project is what I used to learn SystemVerilog, and particularly how to deal with classes in SystemVerilog - so if you're looking for something grand, you're out of luck. If you're looking for a reference to learn SystemVerilog testbench design though, I can help with that!

<br/>

![image](https://github.com/user-attachments/assets/51418bf6-b1b6-4f7b-8413-5241703d05ba) <br/>
Above is the circuit diagram I used as a reference:

<br/>

![image](https://github.com/user-attachments/assets/6d317c75-0f26-493f-b654-47e1c4335251) <br/>
Above is the output waveform from the testbench - there is a delay of two clock cycles between the inputs being fed to the module, and the output being reflected due to the sequential implementation of the circuit. Notice the use of registers in the testbench module to store previous input values to compare with the expected output value in the scoreboard.

<br/>

![image](https://github.com/user-attachments/assets/1aa2273a-824b-4041-921e-00336ab6c7f9) <br/>
Above is the reference I used to structure my testbench:

<br/>

That's it from my side, have fun!


