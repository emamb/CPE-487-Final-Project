# CPE-487-Final-Project
Piano Final Project (Lab 5 Siren Extension)  

Base Code of Lab 5 is provided here: https://github.com/byett/dsd/tree/CPE487-Fall2023/Nexys-A7/Lab-5  

Master file to access different components of the Nexys A7: https://github.com/byett/dsd/blob/CPE487-Fall2023/Nexys-A7/Nexys-A7-100T-Master.xdc  

Implementation of Lab 5 from the group are the files dac_if.vhd, siren.vhd, siren.xdc, tone.vhd, wail.vhd. These are the base for the project code as the Lab gave the siren sound on the waveform that can then be manipulated and implemented in a new way.  

# Piano Final Project
Program the FPGA on the Nexys A7-100T board to generate three different wailing audio sounds that can individually be turned on by using BTNU, BTNC, and BTND buttons. Use a 24-bit digital-to-analog converter (DAC) called Pmod I2S2 (Inter-IC Sound) to the top six pins of the Pmod port JA to output the sounds to a speaker using a 3.5mm audio jack connected to the green port. 

* Pmod I2S2 requires a 3.5-mm connector for a headphone or speaker
* The Digilent Pmod I2S2 features a Cirrus CS5343 Multi-Bit Audio A/D Converter and a Cirrus CS4344 Stereo D/A Converter, each connected to 3.5mm Audio Jacks. These circuits allow a system board to transmit and receive stereo audio signals via the I2S protocol. The Pmod I2S2 supports 24-bit resolution per channel at input sample rates up to 108 KHz.

![i2s2](https://github.com/emamb/CPE-487-Final-Project/assets/98351372/3c5ee11d-ebac-480b-a4a6-51f2f3f2acb0)
![71AqT8JnX8L](https://github.com/emamb/CPE-487-Final-Project/assets/98351372/ab7b93cd-75ce-4b3e-b3b1-042b9558b3bc)
Nexys A7-100T board

The **dac_if** module is designed to convert 16-bit parallel stereo data into a serial format that is compatible with a digital to analog converter. Here's how it operates:
* Whenever L_start is in a high state, it triggers the loading of a 16-bit data word from the left channel into a 16-bit serial shift register (SREG), occurring at the falling edge of the SCLK.
* As soon as L_start transitions to a low state, the SCLK begins to shift the data from SREG, starting with the most significant bit (MSBit), and sends it to the serial output SDATA at a speed of 1.56 Mb/s.
* In a similar manner, a high state of R_start causes the right channel data to be loaded into SREG. This data is subsequently shifted out to SDATA.
* The output data undergoes a change on the falling edge of SCLK. This timing ensures that the data remains stable when the DAC reads it on the SCLK's rising edge.

The **tone** module was originally the barebones of the lab 5 module but was changed with these tweaks:
* Additional Input Ports: In the entity declaration, three new input ports (BTNU_3, BTND_3, BTNC_3) are added. These are likely buttons or inputs used to control the behavior of the module.
* New Signal and Type: A new signal state and a new type state_type are introduced. state_type is an enumeration with four states (IDLE, PLAY_SQUARE_D, PLAY_SQUARE_E, PLAY_SQUARE_F), and state is used to track the current state of the module.
* Amplitude Scaling Factor: A new constant AMPLITUDE_SCALING_FACTOR is defined, which is used to adjust the amplitude of the output signal.
* Modified Count Process: The process cnt_pr that updates the count signal is modified to only increment count when the state is not IDLE. This suggests that the counting (and thus waveform generation) only occurs in active states.
* New Process for State Management and Waveform Generation: A new process is added to handle state transitions based on button inputs and to generate different waveforms based on the current state. This process uses a case statement to determine the output data based on the current state and quad values. The waveforms generated are square waves with amplitudes based on fixed values (98, 110, 117) multiplied by the AMPLITUDE_SCALING_FACTOR, depending on the state.
* Waveform Generation Mechanism Change: The original code generated a triangle wave, whereas the new code generates square waves with different fixed amplitudes depending on the button pressed.
* Removal of Triangle Wave Generation Logic: The logic to generate a triangle wave (using quad and index) is removed in the second version, replaced by the square wave generation logic in the new process.

