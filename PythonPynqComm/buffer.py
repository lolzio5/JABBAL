from pynq import allocate
input_buffer = allocate(shape=(5,), dtype='u4')
input_buffer.device_address
input_buffer[:] = range(5)
input_buffer.flush() #update the buffer to the fpga