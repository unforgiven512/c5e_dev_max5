library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vj_avalon_encode is 
	port (
		system_clk : in std_logic;
		 -- inputs:
		tck : IN STD_LOGIC;
		cdr_in : IN STD_LOGIC;
		ir_in : IN std_logic_vector(1 downto 0);
		data_in : in std_logic_vector(31 downto 0);
		
		read_triger_n : in std_logic;
		waitrequest_n : in std_logic;
		
		-- outputs:
		data_out : OUT STD_LOGIC -- output to VirtualJtag block
	);
end entity vj_avalon_encode;


architecture europa of vj_avalon_encode is
	signal count : integer range 0 to 32;
	signal data_in_int : std_logic_vector(31 downto 0);
	signal waitrequest_d1, waitrequest_d2 : std_logic;

	signal read_triger_n_d : std_logic;
begin

-- ir="00"  :  set data
-- ir="01"  :  used at encoder side
-- ir="10"  :  set address
-- ir="11"  :  set trigger    0:read  1:write


	-- this counter will be counted up by tck of the VirtualJtag clock
	process(tck)begin
		if(tck'event and tck = '1')then
			if(cdr_in = '1' and ir_in = "01")then
				count <= 0;
			else
				if(count = 32)then
					count <= 32;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;

	
	-- parallel to serial conversion
	process(count, data_in_int)begin
		if(count < 31)then
			data_out <= data_in_int(count);
		else
			data_out <= '0';
		end if;
	end process;

	
	process(system_clk)begin
		if(system_clk'event and system_clk = '1')then
			waitrequest_d1 <= not waitrequest_n;
			read_triger_n_d <= read_triger_n;
		end if;
	end process;
	
	waitrequest_d2 <= waitrequest_d1 and waitrequest_n;

	
	-- keep the in coming data
	process(system_clk)begin
		if(system_clk'event and system_clk = '1')then
--			if(reset_triger_n = '0' and waitrequest_d2 = '1' and waitrequest_d1 = '1')then -- reading but not waiting
--			if(waitrequest_d2 = '1')then -- reading but not waiting
			if(read_triger_n_d = '0' and waitrequest_n = '1')then -- reading but not waiting
				data_in_int <= data_in;
			end if;
		end if;
	end process;


end europa;


