# CPE-487-Final-Project
Piano Final Project (Lab 5 Siren Extension)  

Base Code of Lab 5 is provided here: https://github.com/byett/dsd/tree/CPE487-Fall2023/Nexys-A7/Lab-5  

Master file to access different components of the Nexys A7: https://github.com/byett/dsd/blob/CPE487-Fall2023/Nexys-A7/Nexys-A7-100T-Master.xdc  

Implementation of Lab 5 from the group are the files dac_if.vhd, siren.vhd, siren.xdc, tone.vhd, wail.vhd. These are the base for the project code as the Lab gave the siren sound on the waveform that can then be manipulated and implemented in a new way.  

# Piano Final Project
Our group wanted to program the FPGA on the Nexys A7-100T board to generate three different wailing audio sounds that can individually be turned on by using BTNU, BTNC, and BTND buttons to simulate the piano notes: D, E, and F. We used a 24-bit digital-to-analog converter (DAC) called Pmod I2S2 (Inter-IC Sound) to the top six pins of the Pmod port JA to output the sounds to a speaker using a 3.5mm audio jack connected to the green port. 

* Pmod I2S2 requires a 3.5-mm connector for a headphone or speaker
* The Digilent Pmod I2S2 features a Cirrus CS5343 Multi-Bit Audio A/D Converter and a Cirrus CS4344 Stereo D/A Converter, each connected to 3.5mm Audio Jacks. These circuits allow a system board to transmit and receive stereo audio signals via the I2S protocol. The Pmod I2S2 supports 24-bit resolution per channel at input sample rates up to 108 KHz.

**Pmod I2S2**
![i2s2](https://github.com/emamb/CPE-487-Final-Project/assets/98351372/3c5ee11d-ebac-480b-a4a6-51f2f3f2acb0)
![71AqT8JnX8L](https://github.com/emamb/CPE-487-Final-Project/assets/98351372/ab7b93cd-75ce-4b3e-b3b1-042b9558b3bc)
**Nexys A7-100T board**

# Vivado + Nexys Board Steps

# Code Decription
The **dac_if.vhd** file is designed to convert 16-bit parallel stereo data into a serial format that is compatible with a digital to analog converter. Here's how it operates:
* Whenever L_start is in a high state, it triggers the loading of a 16-bit data word from the left channel into a 16-bit serial shift register (SREG), occurring at the falling edge of the SCLK.
* As soon as L_start transitions to a low state, the SCLK begins to shift the data from SREG, starting with the most significant bit (MSBit), and sends it to the serial output SDATA at a speed of 1.56 Mb/s.
* In a similar manner, a high state of R_start causes the right channel data to be loaded into SREG. This data is subsequently shifted out to SDATA.
* The output data undergoes a change on the falling edge of SCLK. This timing ensures that the data remains stable when the DAC reads it on the SCLK's rising edge.

The **tone.vhd** file was originally the barebones of the lab 5 module but was changed with these tweaks:
* Additional Input Ports: In the entity declaration, three new input ports (BTNU_3, BTND_3, BTNC_3) are added. These are the buttons used to play the notes once pressed.
* New Signal and Type: A new signal state and a new type state_type are introduced. state_type is an enumeration with four states (IDLE, PLAY_SQUARE_D, PLAY_SQUARE_E, PLAY_SQUARE_F), and state is used to track the current state of the module.
* Amplitude Scaling Factor: A new constant 'AMPLITUDE_SCALING_FACTOR' is defined, which is used to adjust the amplitude of the output signal. Due to the low nature of Hz of the notes we are trying to replicate, amplitude was used to increase output volume. 
* Modified Count Process: The process cnt_pr that updates the count signal is modified to only increment count when the state is not IDLE. The counting (and thus waveform generation) only occurs in active states.
* New Process for State Management and Waveform Generation: A new process is added to handle state transitions based on button inputs and to generate different waveforms based on the current state. This process uses a case statement to determine the output data based on the current state and quad values. The waveforms generated are square waves with amplitudes based on fixed values (98, 110, 117) multiplied by the AMPLITUDE_SCALING_FACTOR, depending on the state.
* Calculating The Pitch: The Hz for the Square waves were calculated from the fact that for pitch = 1, the frequency would be 0.745 HZ. Using this equation, we were able to dictate the pitch for each note (98 for D, 110 for E, and 117 for F). The Hz for the D note is ~73, ~82 for the E note, and ~87 for the F note.
* Removal of Triangle Wave Generation Logic: The logic to generate a triangle wave (using quad and index) is removed in our version, and the unsigned sawtooth count is made into a signed square wave, and is replaced by the square wave generation logic in the new process. Index is also completley removed since it is not needed in the instances of a square wave.

The **wail.vhd** file was taken from lab 5 and the following changes were made:
* Addition of Button Inputs in Entity Interface: New inputs BTNU_2, BTND_2, and BTNC_2 were added to the entity wail. These are passed from the Siren file to the Wail file.
* Addition of Button Inputs in Component Declaration: The tone component now includes additional inputs BTNU_3, BTND_3, and BTNC_3. These inputs correspond to the button inputs added in the entity. These buttons will be passed to the Tone file.
* Port Map Modifications: In the instantiation of the tone component (tgen), the newly added button inputs (BTNU_2, BTND_2, and BTNC_2) are mapped to the corresponding inputs in the component (BTNU_3, BTND_3, BTNC_3).

The **siren.vhd** file was taken from lab 5 and the following changes were made:
* Additional Input Ports: The ENTITY siren in the second code includes additional input ports: SWITCH, BTNU, BTND, and BTNC. These are not present in the first code.
* Modification in wail_speed Constant: The wail_speed constant in the second code is defined as (OTHERS => '0'), whereas in the first code, it's defined with a specific value to_unsigned (8, 8).
* Component wail Changes: The 'COMPONENT' wail includes additional input ports: BTNU_2, BTND_2, and BTNC_2. These are connected to the newly added input ports BTNU, BTND, and BTNC in the entity port map.

The **siren.xdc** constraint file included three new lines that have been added at the end compared to lab 5 code. These lines are setting properties for additional ports: BTNU, BTND, and BTNC.
* set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
* set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd
* set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
These lines are defining the package pin, I/O standard, and port names for these buttons, which are not present in lab 5 code.
Other than these additions, the rest of the code remains unchanged, maintaining the same clock creation and property settings for the ports clk_50MHz, dac_LRCK, dac_SCLK, dac_SDIN, and dac_MCLK.

# Diagrams
The signal quad is used to generate the square wave, where there are 4 quads made (00, 01, 10, and 11).
* Square wave would be positive from 00 and 01, and negative from 10 and 11, and go back up to a positive pitch from 00 and 01 and this cycle continues.

![index of square](https://github.com/emamb/CPE-487-Final-Project/assets/112715031/b0be5346-2fda-4a97-8b46-296196029e2f)

This block diagram shows how each file connects to one another.
* The siren.xdc file connects to all files, as it defines package pins, I/O Standards, and port names that are used in every file.
* The input first goes to the siren file, where lo_tone, hi_tone, and wail_speed all define the parameters of the siren. the signed audio sequences are sent to the dac_if file to convert them into the required serial stream, and the input buttons are then sent to the wail file.
* The wail file defines the upper and lower limits of the tone and how fast the pitch changes. The wail file passes the input buttons to the tone file.
* The tone file determines the frequency of the tone and the type of wave that is being outputted.

![program diagram](https://github.com/emamb/CPE-487-Final-Project/assets/112715031/44a0adb4-ca1f-4bb0-a0d6-dcf15f2c3ea3)

# Summary + Difficulties Encountered + Conclusions
The group as a whole worked together to think of ways to implement the different notes as the project had many points where it pivoted. Initially, the project wanted to use the sliders to add invididual notes. However, the sliders were not working as intended and we also realized that playing a song through the use of activating and deactivating the sliders would become impractical as the notes would be held for too long. Along with this, the sliders were unable to generate a bitstream and thus caused the first pivot of the project. From here, the idea of having the song played on loop was brainstormed and using the previously implemented quadrants from Lab 5 was attempted. The idea of the implementation was to have the quadrants play a single note in each quadrant that would result in a song playing on a loop due to it being repeated. This would also alleviate the initial issue of practicality of the sliders. This approach did not work in our favor. Initially, the idea was tested with the triangle wave to validate the possibility of using the quadrant with different notes. While editing the frequencies of the notes was a simple change of numbers, doing so without it wailing and removing the triangle wave become a challenge. Since the notes were desired to be clean, in terms of playing a note then releasing it rather than transitioning to the next, index had to be removed. However, when index was removed, there was no transition between the quadrants as an idling sound as the transitions would be too abrupt or harsh. This increased the difficulty of using a square wave for the notes to hit it rather than transitioning and possibly having the notes blurred together. Above all else, a bitstream was never able to be generated from this approach and thus the sound produced was never able to be tested for its quality.[Not sure if we had other failed implemenatations. if so add them here]. The two approaches did leave lessons to use for our final approach. First, while the slider may not have been practical as a note press, a button would be closer to tapping or holding the note for its activation. It would also allow for the square wave to just be activated like the implementation from Lab 5 but rather than having it switch to a square wave, it would be able to switch to a different note. With this, the final approach of the project aimed to use the buttons as the keys with each button on the board having a note assigned to it. This also alleviated the triangle wave and its transitioning issue for using the quadrants as the notes could then be activated from user input rather than attempting to having each note be tied to a quadrant that would be quickly transitioned. [Justin - Add more detail about the implementation that worked]. As with the other approaches, the implementation was not perfect but it did showcase its potential. The notes do play but due to them being low frequency in nature, the speaker has some trouble producing an obvious change in the notes. We also believe that the notes themselves are low resolution in nature as the original lab states the sounds to be 16-bit, or lower if indexed and converted. While the indexing and conversion was removed, it is not entirely known by the group what resolution the noise being produced is at other than it was based on the previously mentioned lab and thus may have a closer resolution to what is stated on there.  
# Final Product Video
https://github.com/emamb/CPE-487-Final-Project/assets/98351372/ddce0ab2-d392-49de-adb0-5b9e614f6140


