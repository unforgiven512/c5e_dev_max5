library ieee;
use ieee.std_logic_1164.all;


						
entity i2c_write is
	port (
		clk: in std_logic;
		reset : in std_logic;
		clk_pls_n: in std_logic;
		clk_pls_p: in std_logic;
		slow_clk : in std_logic;
		address : in std_logic_vector(6 downto 0);

		smb_data_in : in std_logic;
		smb_clk_out : out std_logic;
		smb_data_out : out std_logic;
		data_cont : out std_logic;
		
		short_write : in std_logic;
		send_cmd : in std_logic_vector(7 downto 0);
		send_data : in std_logic_vector(7 downto 0);

		write_done : out std_logic
	);
end i2c_write;

architecture rtl of i2c_write is
	signal counter : integer range 0 to 31;

	signal data_cont_i, data_cont_ii, data_cont_iii : std_logic;
	signal smb_data_int, smb_data_int2, smb_data_int3 : std_logic;
	signal clk_cont : std_logic;
	
	signal clk_mask_low : std_logic;
	signal slow_clk_delay : std_logic;
	
	
begin
	
	process(clk)begin
		if(clk'event and clk = '1')then
			slow_clk_delay <= slow_clk;
		end if;
	end process;

	process(clk, reset)begin
		if(reset = '0')then
			smb_clk_out <= '1';
		elsif(clk'event and clk = '1')then
			smb_clk_out <= ((not clk_cont) or slow_clk_delay) and clk_mask_low;
		end if;
	end process;

	
	process(clk, reset)begin
		if(reset = '0')then
			data_cont <= '0';
			smb_data_out <= '1';
			data_cont_ii <= '0';
			data_cont_iii <= '0';
			smb_data_int2 <= '0';
			smb_data_int3 <= '0';
		elsif(clk'event and clk = '1')then
			if(clk_pls_n = '1')then
				data_cont_ii <= data_cont_i;
				smb_data_int2 <= smb_data_int;
			end if;
			smb_data_int3 <= smb_data_int2;
			smb_data_out <= smb_data_int3;
			data_cont_iii <= data_cont_ii;
			data_cont <= data_cont_iii;
		end if;
	end process;


	process(clk, reset)begin
		if(reset = '0')then
			counter <= 0;
			write_done <= '0';
			clk_mask_low <= '1';			
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
				case counter is
				when 0 =>
					smb_data_int <= '1';
					counter <= 1;
					data_cont_i <= '0';
					clk_cont <= '0';
				when 1 =>
					data_cont_i <= '1'; -- send start bit
					smb_data_int <= '0'; -- start bit as '0'
					counter <= counter + 1;
				when 2 =>
					clk_cont <= '1';
					smb_data_int <= address(6);
					counter <= counter + 1;
				when 3 =>
					smb_data_int <= address(5);
					counter <= counter + 1;
				when 4 =>
					smb_data_int <= address(4);
					counter <= counter + 1;
				when 5 =>
					smb_data_int <= address(3);
					counter <= counter + 1;
				when 6 =>
					smb_data_int <= address(2);
					counter <= counter + 1;
				when 7 =>
					smb_data_int <= address(1);
					counter <= counter + 1;
				when 8 =>
					smb_data_int <= address(0);
					counter <= counter + 1;
				when 9 =>
					smb_data_int <= '0'; -- write sign as '0'
					counter <= counter + 1;
				when 10 =>					
					counter <= counter + 1;
					data_cont_i <= '0'; -- tri-state data output and wait for ACK
				when 11 =>					
					if(smb_data_in = '0')then -- wait for ACK
						counter <= counter + 1;
						data_cont_i <= '1'; -- start sending command data
						smb_data_int <= send_cmd(7);
					else
--						counter <= counter;
						counter <= 0;
					end if;
				when 12 =>
					smb_data_int <= send_cmd(6);
					counter <= counter + 1;
				when 13 =>
					smb_data_int <= send_cmd(5);
					counter <= counter + 1;
				when 14 =>
					smb_data_int <= send_cmd(4);
					counter <= counter + 1;
				when 15 =>
					smb_data_int <= send_cmd(3);
					counter <= counter + 1;
				when 16 =>
					smb_data_int <= send_cmd(2);
					counter <= counter + 1;
				when 17 =>
					smb_data_int <= send_cmd(1);
					counter <= counter + 1;
				when 18 =>
					smb_data_int <= send_cmd(0);
					counter <= counter + 1;
				when 19 =>
					data_cont_i <= '0'; -- tri-state data output and wait for ACK
					counter <= counter + 1;
				when 20 =>	
					if(smb_data_in = '0')then -- wait for ACK
						if(short_write = '1')then -- short write need to finalize transaction
							data_cont_i <= '1'; -- send stop bit
							smb_data_int <= '1'; -- send stop bit
							clk_cont <= '0';
							counter <= counter + 1;
						else
							counter <= counter + 1;
							data_cont_i <= '1';
							smb_data_int <= send_data(7);
						end if;
					else
--						counter <= counter;
						counter <= 0;
					end if;
				when 21 =>
					if(short_write = '1')then
						data_cont_i <= '0'; -- tri-state output
						counter <= 30; -- terminate sub function
						write_done <= '1'; -- indicate finish as '1'
					else
						smb_data_int <= send_data(6);
						counter <= counter + 1;
					end if;
				when 22 =>
					smb_data_int <= send_data(5);
					counter <= counter + 1;
				when 23 =>
					smb_data_int <= send_data(4);
					counter <= counter + 1;
				when 24 =>
					smb_data_int <= send_data(3);
					counter <= counter + 1;
				when 25 =>
					smb_data_int <= send_data(2);
					counter <= counter + 1;
				when 26 =>
					smb_data_int <= send_data(1);
					counter <= counter + 1;
				when 27 =>
					smb_data_int <= send_data(0);
					counter <= counter + 1;
				when 28 =>
					data_cont_i <= '0'; -- tri-state data output and wait for ACK
					counter <= counter + 1;
				when 29 =>
					if(smb_data_in = '0')then -- wait for ACK
						counter <= counter + 1;
						smb_data_int <= '0';
						data_cont_i <= '1';
					else
--						counter <= counter;
						counter <= 0;
					end if;
				when 30 =>
					clk_cont <= '0';
					counter <= counter + 1;
				when 31 =>
					data_cont_i <= '0'; -- tri-state data output and terminate process
					counter <= 31;
					write_done <= '1';
				when others =>
				end case;
			end if;
		end if;
	end process;

end rtl;

