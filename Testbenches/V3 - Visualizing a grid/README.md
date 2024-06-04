## Description of the files I"ve uploaded
Blue square generates... a blue ( more of teal like colour tbh ) squre.  I used this and mixed up the colors + made simple patterns to try and understand how pixels are assinged RGB values.  
The two grid files take an array stored in rom and use a modified pixel streamer module to visualise the array as a grid of ones and zeros. V1 is a simple grid (4x3) and v2 is a much larger grid (80x60).
## How to use it
To get the blue use the same commands ran in for the testbench that visualises the example.

Because the grids are stored in a rom created with verilog we need to make slight adjust to the commands nneded visualise them  
**(1) Run the following commands**  

```
iverilog -o stream streamer_tb.v state_mem.v packer.v test_streamer.v    
vvp stream
gtkwave test.vcd                                                  
```    

**(2) Run the python code to generate an image.**

>The first grid is a little wonky and the logic used to fetch the state of each pixel value is a little off. The second grid uses a much improved method to assign states to pixels
