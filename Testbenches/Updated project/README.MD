They (the testbenches) are a little jank - had to fix frame to 0, not regfile[0].
Commands are in the txt files.
> CHANGED FOR TESTBENCH
> wire [7:0] frame = regfile[0]; - this was fixed to 0 
> When reg 0 is not written too iverilog reads it as xxxx and so r g b are also read as xxxx