# CPE-487-Final-Project
Piano Final Project (Lab 5 Siren Extension)  

Base Code of Lab 5 is provided here: https://github.com/byett/dsd/tree/CPE487-Fall2023/Nexys-A7/Lab-5  

Master file to access different components of the Nexys A7: https://github.com/byett/dsd/blob/CPE487-Fall2023/Nexys-A7/Nexys-A7-100T-Master.xdc  

Implementation of Lab 5 from the group are the files dac_if.vhd, siren.vhd, siren.xdc, tone.vhd, wail.vhd. These are the base for the project code as the Lab gave the siren sound on the waveform that can then be manipulated and implemented in a new way.  

# Piano Final Project
Program the FPGA on the Nexys A7-100T board to generate three different wailing audio sounds that can individually be turned on by using BTNU, BTNC, and BTND buttons. Use a 24-bit digital-to-analog converter (DAC) called Pmod I2S2 (Inter-IC Sound) to the top six pins of the Pmod port JA to output the sounds to a speaker using a 3.5mm audio jack connected to the green port. 
* Pmod I2S2 requires a 3.5-mm connector for a headphone or speaker
![i2s2](https://github.com/emamb/CPE-487-Final-Project/assets/98351372/3c5ee11d-ebac-480b-a4a6-51f2f3f2acb0)

