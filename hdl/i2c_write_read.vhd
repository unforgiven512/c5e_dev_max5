library ieee;
use ieee.std_logic_1164.all;

						
entity i2c_write_read is
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
		
		data_out : out std_logic_vector(7 downto 0);
		send_cmd : in std_logic_vector(7 downto 0);
		send_data : in std_logic_vector(7 downto 0);

		write_read_done : out std_logic
	);
end i2c_write_read;

architecture rtl of i2c_write_read is
	signal counter : integer range 0 to 51;
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
			write_read_done <= '0';
			data_cont_i <= '0';
			clk_cont <= '0';
			clk_mask_low <= '1';
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
				if(counter = 0)then
					smb_data_int <= '1';
					counter <= 1;
					data_cont_i <= '0';
					clk_cont <= '0';
				elsif(counter = 1)then
					data_cont_i <= '1'; -- send start bit
					smb_data_int <= '0'; -- start bit as '0'
					counter <= counter + 1;
				elsif(counter = 2)then
					clk_cont <= '1';
					smb_data_int <= address(6);
					counter <= counter + 1;
				elsif(counter = 3)then
					smb_data_int <= address(5);
					counter <= counter + 1;
				elsif(counter = 4)then
					smb_data_int <= address(4);
					counter <= counter + 1;
				elsif(counter = 5)then
					smb_data_int <= address(3);
					counter <= counter + 1;
				elsif(counter = 6)then
					smb_data_int <= address(2);
					counter <= counter + 1;
				elsif(counter = 7)then
					smb_data_int <= address(1);
					counter <= counter + 1;
				elsif(counter = 8)then
					smb_data_int <= address(0);
					counter <= counter + 1;
				elsif(counter = 9)then
					smb_data_int <= '0'; -- write sign as '0'
					counter <= counter + 1;
				elsif(counter = 10)then
					counter <= counter + 1;
					data_cont_i <= '0'; -- tri-state data output and wait for ACK
				elsif(counter = 11)then
					if(smb_data_in = '0')then -- wait for ACK
						counter <= counter + 1;
						data_cont_i <= '1'; -- start sending command data / register address
						smb_data_int <= send_cmd(7);
					else
--						counter <= counter;
						counter <= 0;
					end if;
				elsif(counter = 12)then
					smb_data_int <= send_cmd(6);
					counter <= counter + 1;
				elsif(counter = 13)then
					smb_data_int <= send_cmd(5);
					counter <= counter + 1;
				elsif(counter = 14)then
					smb_data_int <= send_cmd(4);
					counter <= counter + 1;
				elsif(counter = 15)then
					smb_data_int <= send_cmd(3);
					counter <= counter + 1;
				elsif(counter = 16)then
					smb_data_int <= send_cmd(2);
					counter <= counter + 1;
				elsif(counter = 17)then
					smb_data_int <= send_cmd(1);
					counter <= counter + 1;
				elsif(counter = 18)then
					smb_data_int <= send_cmd(0);
					counter <= counter + 1;
				elsif(counter = 19)then
					data_cont_i <= '0'; -- tri-state data output and wait for ACK
					counter <= counter + 1;
				elsif(counter = 20)then
					if(smb_data_in = '0')then -- wait for ACK
						clk_cont <= '1';
						counter <= counter + 1;
					else
--						counter <= counter;
						counter <= 0;
					end if;
				elsif(counter = 21)then
					clk_mask_low <= '0';
					clk_cont <= '0';
					counter <= counter + 1;

				elsif(counter = 22)then
					counter <= counter + 1;
				elsif(counter = 23)then
					counter <= counter + 1;
				elsif(counter = 24)then
					counter <= counter + 1;
				elsif(counter = 25)then
					counter <= counter + 1;
				elsif(counter = 26)then
					counter <= counter + 1;
				elsif(counter = 27)then
					clk_mask_low <= '1';
					counter <= counter + 1;
					
-- from here is the read section					
				elsif(counter = 28)then
					smb_data_int <= '1';
					data_cont_i <= '0';
					clk_cont <= '0';
					counter <= counter + 1;
				elsif(counter = 29)then
					data_cont_i <= '1';
					smb_data_int <= '0';
					counter <= counter + 1;
				elsif(counter = 30)then
					clk_cont <= '1';
					smb_data_int <= address(6);
					counter <= counter + 1;
				elsif(counter = 31)then
					smb_data_int <= address(5);
					counter <= counter + 1;
				elsif(counter = 32)then
					smb_data_int <= address(4);
					counter <= counter + 1;
				elsif(counter = 33)then
					smb_data_int <= address(3);
					counter <= counter + 1;
				elsif(counter = 34)then
					smb_data_int <= address(2);
					counter <= counter + 1;
				elsif(counter = 35)then
					smb_data_int <= address(1);
					counter <= counter + 1;
				elsif(counter = 36)then
					smb_data_int <= address(0);
					counter <= counter + 1;
				elsif(counter = 37)then
					smb_data_int <= '1'; -- read sign is 1
					counter <= counter + 1;
				elsif(counter = 38)then
					counter <= counter + 1;
					data_cont_i <= '0';
				elsif(counter = 39)then
					if(smb_data_in = '0')then
						counter <= counter + 1;
					else
--						counter <= counter;
						counter <= 0;
					end if;
				elsif(counter = 40)then
					data_out(7) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 41)then
					data_out(6) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 42)then
					data_out(5) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 43)then
					data_out(4) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 44)then
					data_out(3) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 45)then
					data_out(2) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 46)then
					data_out(1) <= smb_data_in;
					counter <= counter + 1;
				elsif(counter = 47)then
					data_out(0) <= smb_data_in;
					counter <= counter + 1;
					smb_data_int <= '1'; -- NAC bit
					clk_cont <= '1';
					data_cont_i <= '1';
				elsif(counter = 48)then
					clk_cont <= '1';
					smb_data_int <= '0';
					data_cont_i <= '1';
					counter <= counter + 1;
				elsif(counter = 49)then
					clk_cont <= '0';
					smb_data_int <= '1';
					data_cont_i <= '0';
					counter <= counter + 1;
				elsif(counter = 50)then
					counter <= counter + 1;
				elsif(counter = 51)then
					write_read_done <= '1';				
					counter <= counter;
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;
end rtl;

