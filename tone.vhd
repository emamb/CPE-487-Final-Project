LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Generates a 16-bit signed triangle wave sequence at a sampling rate determined
-- by input clk and with a frequency of (clk*pitch)/65,536
ENTITY tone IS
	PORT (
	   BTNU_3 : IN STD_LOGIC;
		clk : IN STD_LOGIC; -- 48.8 kHz audio sampling clock
		pitch : IN UNSIGNED (13 DOWNTO 0); -- frequency (in units of 0.745 Hz)
	data : OUT SIGNED (15 DOWNTO 0)); -- signed triangle wave out
END tone;

ARCHITECTURE Behavioral OF tone IS
	SIGNAL count : unsigned (15 DOWNTO 0); -- represents current phase of waveform
	SIGNAL quad : std_logic_vector (1 DOWNTO 0); -- current quadrant of phase
	SIGNAL index : signed (15 DOWNTO 0); -- index into current quadrant
BEGIN
	-- This process adds "pitch" to the current phase every sampling period. Generates
	-- an unsigned 16-bit sawtooth waveform. Frequency is determined by pitch. For
	-- example when pitch=1, then frequency will be 0.745 Hz. When pitch=16,384, frequency
	-- will be 12.2 kHz.
	cnt_pr : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk);
		count <= count + pitch;
	END PROCESS;
	quad <= std_logic_vector (count (15 DOWNTO 14)); -- splits count range into 4 phases
	index <= signed ("00" & count (13 DOWNTO 0)); -- 14-bit index into the current phase
	-- This select statement converts an unsigned 16-bit sawtooth that ranges from 65,535
	-- into a signed 12-bit triangle wave that ranges from -16,383 to +16,383
		PROCESS
	BEGIN
        IF BTNU_3 = '1' THEN -- Square Wave
            IF quad = "00" OR quad = "01" THEN
                data <= to_signed(16383, data'length);
            ELSE
                data <= to_signed(-16383, data'length); 
            END IF;
        ELSIF BTNU_3 = '0' THEN   -- Triangle Wave
            IF quad = "00" THEN
                data <= index; 
            ELSIF quad = "01" THEN
                data <= to_signed(16383, data'length) - index; 
            ELSIF quad = "10" THEN
                data <= to_signed(0, data'length) - index; 
            ELSE
                data <= index - to_signed(16383, data'length);
            END IF;
        END IF;
    END PROCESS;
END Behavioral;
