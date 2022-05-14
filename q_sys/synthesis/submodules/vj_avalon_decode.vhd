library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vj_avalon_decode is 
	port (
		  -- inputs:
		system_clk : in std_logic;
		clk_pls_p: in std_logic;

		tck 		: in std_logic; -- clock comming from VirtualJtag block to latch VJ data
		data_in 	: IN STD_LOGIC; -- data comming from VirtualJtag block
		ir_in 	: IN std_logic_vector(1 downto 0); -- Instruction register info comming from VJ
		sdr_in 	: IN STD_LOGIC; -- data shift start signal
		e1dr_in 	: in std_logic; -- end of data indicator
		reset_in : in std_logic;
		waitrequest_n : in std_logic;
		
		  -- outputs:
		data_out 		: out std_logic_vector(31 downto 0);
		address_out 	: out std_logic_vector(31 DOWNTO 0);
		write_triger_n 	: out std_logic;
		read_triger_n 	: out std_logic
	);
end entity vj_avalon_decode;


architecture rtl of vj_avalon_decode is
	signal data_in_int : std_logic;
	signal address_int : std_logic_vector(31 downto 0);
	signal data_int : std_logic_vector(31 downto 0):=(others => '0');
	
	signal write_triger_n_int 	: std_logic;
	signal read_triger_n_int 	: std_logic;
	signal write_triger_n_sysCLK 	: std_logic;
	signal read_triger_n_sysCLK 	: std_logic;
	
	signal waitrequest_pls1, waitrequest_pls2, waitrequest_pls : std_logic;
	signal wdt : integer range 0 to 255;
begin


-- ir="00"  :  set data
-- ir="01"  :  used at encoder side
-- ir="10"  :  set address
-- ir="11"  :  set trigger    0:read  1:write



-- setting read/write address ir="10" 32 bits signal
	process(tck)begin
		if(tck'event and tck = '1')then
			if(sdr_in = '1' and ir_in = "10")then -- start data shift
				address_int(30 downto 0) <= address_int(31 downto 1);
				address_int(31) <= data_in;
			end if;
		end if;
	end process;

	process(tck)begin
		if(tck'event and tck = '1')then
			if(e1dr_in = '1' and ir_in = "10")then -- detected the end of data
				address_out <= address_int;
			end if;
		end if;
	end process;

-- setting 32 bits signal
-- 01 is used on read(encoder) side
	process(tck, reset_in)begin
		if(reset_in = '0')then
			data_int <= (others => '0');
		elsif(tck'event and tck = '1')then
			if(sdr_in = '1' and ir_in = "00")then
				data_int(30 downto 0) <= data_int(31 downto 1);
				data_int(31) <= data_in;
			end if;
		end if;
	end process;

	process(tck, reset_in)begin
		if(reset_in = '0')then
		elsif(tck'event and tck = '1')then
			if(e1dr_in = '1' and ir_in = "00")then
				data_out <= data_int;
			end if;
		end if;
	end process;


	
	
	process(reset_in, system_clk)begin
		if(reset_in = '0')then
			waitrequest_pls1 <= '1';
		elsif(system_clk'event and system_clk = '1')then
			waitrequest_pls1 <= not waitrequest_n;
		end if;
	end process;
	
	waitrequest_pls <= waitrequest_pls1 and waitrequest_n;
	
-- setting reset signal ir="11"
	process(waitrequest_pls, wdt, tck)begin
		if(waitrequest_pls = '1' or wdt = 255)then
			write_triger_n_int <= '1';
			read_triger_n_int <= '1';
		elsif(tck'event and tck = '1')then
			if(sdr_in = '1' and ir_in = "11")then
				if(data_in = '0')then
					write_triger_n_int <= '1';
					read_triger_n_int <= '0';
				else
					write_triger_n_int <= '0';
					read_triger_n_int <= '1';
				end if;
			end if;
		end if;
	end process;

	-- e1dr is short '1' pulse, it is the timing to latch the data
	process(waitrequest_pls, wdt, tck)begin
		if(waitrequest_pls = '1' or wdt = 255)then -- 0: wait for the compleation of the process  1: process completed
			write_triger_n_sysCLK <= '1';
			read_triger_n_sysCLK <= '1';				
		elsif(tck'event and tck = '1')then
--			if(sdr_in = '1' and ir_in = "11")then
			if(e1dr_in = '1' and ir_in = "11")then -- this should be e1dr_in rather than sdr_in
				write_triger_n_sysCLK <= write_triger_n_int;
				read_triger_n_sysCLK <= read_triger_n_int;
			end if;
		end if;
	end process;

	-- change the clk domain from tck to system_clk at here
	process(waitrequest_pls, wdt, system_clk)begin
		if(waitrequest_pls = '1' or wdt = 255)then
			write_triger_n <= '1';
			read_triger_n <= '1';
		elsif(system_clk'event and system_clk = '1')then
			write_triger_n <= write_triger_n_sysCLK;
			read_triger_n <= read_triger_n_sysCLK;
		end if;
	end process;
	
	process(write_triger_n_sysCLK, read_triger_n_sysCLK, system_clk)begin
		if(write_triger_n_sysCLK = '1' and read_triger_n_sysCLK = '1')then
			wdt <= 0;
		elsif(system_clk'event and system_clk = '1')then
			if(clk_pls_p = '1')then
				if(wdt = 255)then
					wdt <= 255;
				else
					wdt <= wdt + 1;
				end if;
			end if;
		end if;
	end process;
	
end rtl;

