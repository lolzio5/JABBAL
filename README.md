# JABBAL - Simulating Conway's Game of Life at 200,000 FPS
## Abstract
Conway’s Game of Life, a well-known cellular automaton consisting of an infinite size grid of “alive” and “dead” cells. These cells evolve based on the number of “alive” Moore neighbours they have, where the next state of each cell is determined by its current state and the state of its current 8 neighbours. Calculating the next state for large grid sizes is computationally expensive but can be parallelised well. Therefore, we present an implementation of Conway’s Game of Life for a native resolution grid (1280x720), using custom FPGA logic to accelerate the next state calculations along with modern computer vision techniques to devise an inclusive and intuitive user interface (UI). Our system generates frames at 60Hz, with potential for a staggering 200kHz frame rate if there was no monitor. Moreover, users can input any initial grid of “alive” cells through simple hand gestures, and each current generation can be studied with an intuitive pause function that works in real time.

## System Overview
Our system consists of three separate pieces of hardware - a laptop, the PYNQ-Z1 FPGA board and the monitor. A user interface runs on the laptop and allows the user to initialise the first generation. It also sends signals to the board for starting and stopping the visualisation. The FPGA performs calculations related to finding the next generation and is also responsible for generating the visualisation of the changing states via an HDMI out port connected to a monitor. For details on how each part of how the system works, please refer to the report: [JabbalReport.pdf](https://github.com/lolzio5/JABBAL/blob/main/JabbalReport.pdf)

## Usage
To run the system, a laptop with an installed Python interpreter, a PYNQ-Z1 board and a 60Hz monitor with HDMI output is required. 

1. To set up the PYNQ-Z1 board, please follow the [PYNQ Setup Guide](https://pynq.readthedocs.io/en/latest/getting_started/pynq_z1_setup.html) to open the Jupyter Notebook, and connect the HDMI monitor.
2. Copy the [base15A.bit](https://github.com/lolzio5/JABBAL/blob/main/Generated%20bit%20and%20hwh%20files/base15A.bit) and [base15A.hwh](https://github.com/lolzio5/JABBAL/blob/main/Generated%20bit%20and%20hwh%20files/base15A.hwh) to the home directory /user/xilinx on the PYNQ.
3. Copy [PYNQ_Notebook_Final.ipynb](https://github.com/lolzio5/JABBAL/blob/main/Notebooks/PYNQ_Notebook_Final.ipynb) to the home directory /user/xilinx on the PYNQ and open it.
4. In a Python Environment, run the command
   ```shell
   pip install -r requirements.txt
   ```
6. Once all packages are installed, run the [hand_distance_new.py](https://github.com/lolzio5/JABBAL/blob/main/UI/hand_detection/hand_distance_new.py) file in a Python environment
7. When the following message appears in the Python terminal, execute all the cells in the Jupyter Notebook, except the last one (that sets the speedup)
   ```
   Waiting for a connection...
   ```
8. Once the client and server are connected, you should be able to move your hand be detected. Pinch your fingers together to draw!
9. When you're finished drawing, show a thumbs up and wait a few seconds. You should see the pattern start appearing on the screen, and immediately start evolving.
10. To pause the pattern, simply open your hand showing your palm and stretched fingers to the camera

