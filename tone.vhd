LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tone IS
    PORT (
        BTNU_3 : IN STD_LOGIC;
        BTND_3 : IN STD_LOGIC;
        BTNC_3 : IN STD_LOGIC;
        clk : IN STD_LOGIC; -- 48.8 kHz audio sampling clock
        pitch : IN UNSIGNED (13 DOWNTO 0); -- frequency (in units of 0.745 Hz)
        data : OUT SIGNED (15 DOWNTO 0)
    ); -- signed triangle wave out
END tone;

ARCHITECTURE Behavioral OF tone IS
    TYPE state_type IS (IDLE, PLAY_SQUARE_D, PLAY_SQUARE_E, PLAY_SQUARE_F);
    SIGNAL state : state_type := IDLE;
    SIGNAL count : UNSIGNED (15 DOWNTO 0); -- represents the current phase of waveform
    SIGNAL quad : STD_LOGIC_VECTOR (1 DOWNTO 0); -- current quadrant of phase
    CONSTANT AMPLITUDE_SCALING_FACTOR : INTEGER := 130; -- Adjust this factor as needed
BEGIN
    -- This process adds "pitch" to the current phase every sampling period. Generates
    -- an unsigned 16-bit sawtooth waveform. Frequency is determined by pitch. For
    -- example when pitch=1, then frequency will be 0.745 Hz. When pitch=16,384, frequency
    -- will be 12.2 kHz.
    cnt_pr : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk);
        IF state /= IDLE THEN
            count <= count + pitch;
        END IF;
    END PROCESS;

    quad <= STD_LOGIC_VECTOR(count(15 DOWNTO 14)); -- splits count range into 4 phases

    -- This select statement converts an unsigned 16-bit sawtooth that ranges from 65,535
    -- into a signed 12-bit triangle wave that ranges from -16,383 to +16,383
    PROCESS
    BEGIN
        CASE state IS
            WHEN IDLE =>
                data <= (OTHERS => '0'); -- nothing to play if no button is pressed
                IF BTNU_3 = '1' THEN
                    state <= PLAY_SQUARE_D;
                ELSIF BTND_3 = '1' THEN
                    state <= PLAY_SQUARE_E;
                ELSIF BTNC_3 = '1' THEN
                    state <= PLAY_SQUARE_F;
                END IF;
            WHEN PLAY_SQUARE_D =>
                IF BTNU_3 = '0' THEN
                    state <= IDLE;
                    data <= (OTHERS => '0');
                ELSE
                    IF quad = "00" OR quad = "01" THEN
                        data <= TO_SIGNED(98 * AMPLITUDE_SCALING_FACTOR, data'length);
                    ELSE
                        data <= TO_SIGNED(-98 * AMPLITUDE_SCALING_FACTOR, data'length);
                    END IF;
                END IF;
            WHEN PLAY_SQUARE_E =>
                IF BTND_3 = '0' THEN
                    state <= IDLE;
                    data <= (OTHERS => '0');
                ELSE
                    IF quad = "00" OR quad = "01" THEN
                        data <= TO_SIGNED(110 * AMPLITUDE_SCALING_FACTOR, data'length);
                    ELSE
                        data <= TO_SIGNED(-110 * AMPLITUDE_SCALING_FACTOR, data'length);
                    END IF;
                END IF;
            WHEN PLAY_SQUARE_F =>
                IF BTNC_3 = '0' THEN
                    state <= IDLE;
                    data <= (OTHERS => '0');
                ELSE
                    IF quad = "00" OR quad = "01" THEN
                        data <= TO_SIGNED(117 * AMPLITUDE_SCALING_FACTOR, data'length);
                    ELSE
                        data <= TO_SIGNED(-117 * AMPLITUDE_SCALING_FACTOR, data'length);
                    END IF;
                END IF;
        END CASE;
    END PROCESS;
END Behavioral;

