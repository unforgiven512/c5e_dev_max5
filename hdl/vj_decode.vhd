library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vj_decode is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal ir_in : IN std_logic_vector(2 downto 0);
                 signal cdr_in : IN STD_LOGIC;
                 signal sdr_in : IN STD_LOGIC;
                 signal e1dr : in std_logic;
                 
                 signal system_clk : in std_logic;
                 signal reset_n : in std_logic;

              -- outputs:
				signal data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
				signal clk_out : out std_logic;
				signal clk_int_out : out std_logic;
				signal nConfig_test : out std_logic;
				signal decode_reset : out std_logic;
				signal decode_sel : out std_logic
              );
end entity vj_decode;


architecture europa of vj_decode is
	signal count : integer range 0 to 31;
	signal sdr_in_d : std_logic;
	signal data_in_int : std_logic_vector(31 downto 0);
	signal clk_int0, clk_int1, clk_int2, clk_int3 : std_logic;
	signal clk_d1, clk_d2, clk_d3, clk_d4 : std_logic;
	
	signal clk_out_ok : std_logic;
	signal count_ok : std_logic;
	signal count_ok_d : std_logic_vector(7 downto 0);
	
--	signal clk_in_d1, clk_in_d2, clk_int : std_logic;
--	signal clk_in_d1, clk_in_d2 : std_logic;
	signal data_out_int : std_logic_vector(15 downto 0);
	signal decode_reset_int : std_logic;
	signal detection : std_logic;
	
	signal clk_count : integer;
	signal clk_out_int : std_logic;
	
	signal wait_counter : integer range 0 to 63;
	
begin

	-- this wait_coutner will be used to detect the delay of the jtag to actual data.
	process(reset_n, clk)begin
		if(reset_n = '0')then
			wait_counter <= 0;
		elsif(clk'event and clk = '1')then
			if(cdr_in = '1' and ir_in = "111")then
				wait_counter <= 0;
			elsif(sdr_in = '1' and e1dr = '0' and ir_in = "111")then
				wait_counter <= wait_counter + 1; -- it will count 1 extra
			elsif(sdr_in = '0' and e1dr = '1' and ir_in = "111")then
				wait_counter <= wait_counter - 1; -- so, we need to subtruct 1 at here
			end if;
		end if;
	end process;

	

	process(reset_n, clk)begin
		if(reset_n = '0')then
			nConfig_test <= '1';
			count <= 0;
			count_ok <= '0';	
			count_ok_d <= (others => '0');
		elsif(clk'event and clk = '1')then
			if(cdr_in = '1')then
--				count <= 0;
				count_ok <= '1';
				count_ok_d <= (others => '0');
			elsif(count_ok = '1' and wait_counter > 1)then
				count <= 0;
				count_ok_d <= count_ok_d + 1;
--				if(count_ok_d = x"6")then
				if(count_ok_d = wait_counter)then
					count_ok <= '0';
					count_ok_d <= (others => '0');
				end if;
			else
				if(ir_in = "100" and sdr_in = '1')then -- 3
					if(count = 31)then
						count <= 0;
					else
						count <= count + 1;
					end if;
					nConfig_test <= '1';
				elsif(ir_in = "101")then -- 4
					nConfig_test <= '1';
				elsif(ir_in = "111")then -- 2
					nConfig_test <= '0';
				elsif(ir_in = "110")then -- 1
					nConfig_test <= '1';
					count <= 0;
					count_ok <= '0';	
				else
					nConfig_test <= '1';
				end if;
			end if;
		end if;
	end process;
	
	process(clk)begin
		if(clk'event and clk = '1')then
			data_in_int(count) <= data_in;
	
--			case count is
--				when 0 => data_in_int(0) <= data_in;
--				when 1 => data_in_int(1) <= data_in;
--				when 2 => data_in_int(2) <= data_in;
--				when 3 => data_in_int(3) <= data_in;
--				when 4 => data_in_int(4) <= data_in;
--				when 5 => data_in_int(5) <= data_in;
--				when 6 => data_in_int(6) <= data_in;
--				when 7 => data_in_int(7) <= data_in;
--				when others => null;
--			end case;
		end if;
	end process;

		process(clk)begin
		if(clk'event and clk = '1')then
			if(sdr_in = '1' or e1dr = '1')then
				if(count = 15  and ir_in = "100")then
					data_out_int(14 downto 0) <= data_in_int(14 downto 0);
					data_out_int(15) <= data_in;
				end if;
			end if;
		end if;
	end process;

	process(clk)begin
		if(clk'event and clk = '1')then
				if(count = 15 and sdr_in = '1')then
				clk_int0 <= '1';
			else
				clk_int0 <= '0';
			end if;
		end if;
	end process;
	
	process(system_clk, e1dr)begin
		if(system_clk'event and system_clk = '1')then
			if(ir_in = "100")then
				clk_out_int <= clk_d4;
				clk_d4 <= clk_d3;
				clk_d3 <= clk_d2;
				clk_d2 <= clk_d1;
				clk_d1 <= clk_int0 or e1dr;
				
				clk_int_out <= clk_d3 and (not clk_d4);
				
			else
				clk_out_int <= '0';
			end if;
		end if;
	end process;
	clk_out <= clk_out_int;

	process(system_clk)begin
		if(system_clk'event and system_clk = '1')then
			data_out <= data_out_int;
		end if;
	end process;
	
	process(clk)begin
		if(clk'event and clk = '1')then
			if(ir_in = "110")then
				decode_reset_int <= '0';
			else
				decode_reset_int <= '1';
			end if;
		end if;
	end process;
	


	process(system_clk)begin
		if(system_clk'event and system_clk = '1')then
			if(decode_reset_int = '0')then
				detection <= '1';		
			elsif(detection = '1')then
				if((clk_d3 and (not clk_d4)) = '1')then -- same as clk_int_out signal
					decode_sel <= data_out_int(15); -- 0:SRLE    1:RBF
					detection <= '0';
				end if;
			end if;
		end if;
	end process;

	
	process(sdr_in, clk_out_int)begin
		if(sdr_in = '0')then
			clk_count <= 0;
		elsif(clk_out_int'event and clk_out_int = '1')then
			clk_count <= clk_count + 1;
		end if;
	end process;

	process(clk_count)begin
		if(clk_count = 0)then
			decode_reset <= '1';
		else
			decode_reset <= decode_reset_int;
		end if;
	end process;
	
end europa;
