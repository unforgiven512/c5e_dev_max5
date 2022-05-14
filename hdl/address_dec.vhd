library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity address_dec is 
        port (
              -- inputs:
				clk : in std_logic;
                 data_in : IN STD_LOGIC;
                 ir_in : IN std_logic_vector(1 downto 0);
                 sdr_in : IN STD_LOGIC;
                 e1dr_in : in std_logic;
				reset_in : in std_logic;

              -- outputs:
                 control_out : out std_logic_vector(7 downto 0);
                 address_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				reset_n : out std_logic
              );
end entity address_dec;


architecture rtl of address_dec is
	signal data_in_int : std_logic;
	signal address_int : std_logic_vector(3 downto 0);
	signal control_int : std_logic_vector(7 downto 0):=(others => '0');
begin

-- setting read address ir="10" 4 bits signal
	process(clk)begin
		if(clk'event and clk = '1')then
			if(sdr_in = '1' and ir_in = "10")then
				address_int(2 downto 0) <= address_int(3 downto 1);
				address_int(3) <= data_in;
			end if;
		end if;
	end process;

	process(clk)begin
		if(clk'event and clk = '1')then
			if(e1dr_in = '1' and ir_in = "10")then
				address_out <= address_int;
			end if;
		end if;
	end process;

-- setting GUI control ir="00" 8 bits signal
-- 01 is used on read(encoder) side
	process(clk, reset_in)begin
		if(reset_in = '0')then
			control_int <= (others => '0');
		elsif(clk'event and clk = '1')then
			if(sdr_in = '1' and ir_in = "00")then
				control_int(6 downto 0) <= control_int(7 downto 1);
				control_int(7) <= data_in;
			end if;
		end if;
	end process;

	process(clk, reset_in)begin
		if(reset_in = '0')then
			control_out <= (others => '0');
		elsif(clk'event and clk = '1')then
			if(e1dr_in = '1' and ir_in = "00")then
				control_out <= control_int;
			end if;
		end if;
	end process;


-- setting reset signal ir="11"
	process(clk, reset_in)begin
		if(reset_in = '0')then
			reset_n <= '1';
		elsif(clk'event and clk = '1')then
			if(sdr_in = '1' and ir_in = "11")then
				reset_n <= '0';
			else
				reset_n <= '1';
			end if;
		end if;
	end process;

end rtl;


