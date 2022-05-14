library ieee;
use ieee.std_logic_1164.all;

entity i2c_cont_bridge is
	port (
		reset_n: in std_logic;
		clk : in std_logic;
		
		-- interface for AvMM-master
		mstr_en_n : out std_logic;
		mstr_address : out std_logic_vector(9 downto 0);
		mstr_write_n : out std_logic;
		mstr_read_n : out std_logic;
		mstr_data_in : in  std_logic_vector(31 downto 0);
		mstr_data_out : out std_logic_vector(31 downto 0);
		mstr_waitrequest_n : in std_logic;


		-- interface for AvMM-slave
		slv_en_n : in std_logic;
		slv_address : in std_logic_vector(9 downto 0);
		slv_read_n : in std_logic;
		slv_write_n : in std_logic;
		slv_data_in : in  std_logic_vector(31 downto 0);
		slv_data_out : out std_logic_vector(31 downto 0);
		slv_waitrequest_n : out std_logic -- 0: under process   1:process done, same ad wait_n
		
	);
end i2c_cont_bridge;


architecture rtl of i2c_cont_bridge is


	signal dev_address : std_logic_vector(7 downto 0); -- 7bits device mstr_address
	signal reg_add : std_logic_vector(7 downto 0); -- register address to access
	
	
	signal slv_address_int : std_logic_vector(8 downto 0); -- 9bits
	signal slv_data_in_int : std_logic_vector(31 downto 0);
	signal slv_data_out_int : std_logic_vector(31 downto 0);

	signal reset_n_int : std_logic;
	signal process_done_int, process_done_int2, process_done_int3 : std_logic;
	
	signal write_data : std_logic_vector(7 downto 0);
	signal command_r_n, command_w_n : std_logic;
	signal command_r_n2, command_w_n2 : std_logic_vector(4 downto 0);
	signal command_r_n_d, command_w_n_d : std_logic;
	
	signal data_mon : std_logic_vector(7 downto 0);
	
	
--	type STATE_TYPE is (S1, S2, S3, S4, S5, S6, S7); 
	type STATE_TYPE is (IDL, 
								S_init_1, S_init_2,S_init_3,S_init_4,S_init_5,
								S_read_1, S_read_2, S_read_3, S_read_4, S_read_5, S_read_6, S_read_7, S_read_8, S_read_9, S_read_10, S_read_11, S_read_12, 
								S_write_1,S_write_2, S_write_3, S_write_4, S_write_5, S_write_6, S_write_7, S_write_8, S_write_9
								); 
	signal CS, NS: STATE_TYPE;
	
	signal mstr_address_int : std_logic_vector(7 downto 0);
	signal mstr_data_out_int : std_logic_vector(7 downto 0);
	signal slv_en_n_d : std_logic_vector(3 downto 0);
begin

	process(clk, reset_n)begin
		if(reset_n = '0')then
			write_data <= (others => '0');
			command_r_n <= '0';
			command_w_n <= '0';
--			reset_n_int <= '0';
		elsif(clk'event and clk = '1')then
			if(slv_en_n = '0' and slv_address(9 downto 8) = "00")then
				write_data <= slv_data_in(7 downto 0);
				command_r_n <= not slv_read_n;
				command_w_n <= not slv_write_n;
--				reset_n_int <= '1';
			else
				write_data <= (others => '0');
				command_r_n <= '0';
				command_w_n <= '0';
--				reset_n_int <= '0';
			end if;
		end if;
	end process;
	
	command_r_n_d <= command_r_n or slv_read_n or slv_address(8) or slv_address(9);
	command_w_n_d <= command_w_n or slv_write_n or slv_address(8) or slv_address(9);
	
	process(clk)begin
		if(clk'event and clk = '1')then
			command_r_n2(4 downto 1) <= command_r_n2(3 downto 0);
			command_w_n2(4 downto 1) <= command_w_n2(3 downto 0);
			command_r_n2(0) <= command_r_n;
			command_w_n2(0) <= command_w_n;
		end if;
	end process;

	process(clk)begin
		if(clk'event and clk = '1')then
			slv_en_n_d(3 downto 1) <= slv_en_n_d(2 downto 0);
			slv_en_n_d(0) <= not slv_en_n;
		end if;
	end process;
--	process(slv_en_n, slv_address, process_done_int, process_done_int2, process_done_int3)begin
	process(slv_en_n, slv_address, slv_en_n, process_done_int)begin
		if(slv_en_n = '1')then
			slv_waitrequest_n <= '1';
		elsif(slv_address(8) = '1' or slv_address(9) = '1')then
			slv_waitrequest_n <= slv_en_n_d(3);
		else
--			slv_waitrequest_n <= process_done_int and process_done_int2 and process_done_int3;
			slv_waitrequest_n <= process_done_int;
		end if;
	end process;
	
	process(clk, reset_n)begin
		if(reset_n = '0')then
			process_done_int3 <= '1';
			process_done_int2 <= '1';
		elsif(clk'event and clk = '1')then
			process_done_int3 <= process_done_int2;
			process_done_int2 <= mstr_waitrequest_n;
		end if;
	end process;


	process(clk, reset_n)begin
		if(reset_n = '0')then
			slv_data_out_int(31 downto 8) <= (others => '1'); -- data not ready
		elsif(clk'event and clk = '1')then
			if(slv_en_n = '0' and process_done_int = '1')then
				slv_data_out_int(31 downto 8) <= (others => '0'); -- data is ready
			else
				slv_data_out_int(31 downto 8) <= (others => '1'); -- data not ready
			end if;
		end if;
	end process;



	-- Those codes are just to make Quartus happy.
	-- Some how, the bus will be optimized and can not get correct value.
	-- In order to avoid that, I had to use all the data to prevent dropping in compilation.
	process(clk, reset_n)begin
		if(reset_n = '0')then
			dev_address <= x"00";
		elsif(clk'event and clk = '1')then
			if(slv_address(9 downto 8) = "01" and slv_write_n = '0')then
				dev_address(7 downto 0) <= slv_address(7 downto 0);
			elsif(slv_address(9 downto 8) = "10" and slv_write_n = '0')then
				reg_add(7 downto 0) <= slv_address(7 downto 0);
			end if;
		end if;
	end process;

	-- I AM USING ALL DATA BUS!!! DO NOT DROP IT!!!
	process(slv_data_out_int)begin
		if(slv_data_out_int(31 downto 8) = x"000000")then
			slv_data_out(31) <= '0';
		else
			slv_data_out(31) <= '1';		
		end if;
	end process;

	slv_data_out(30 downto 0) <= slv_data_out_int(30 downto 0);
	

	----------------------------------------------------------------
	-- from here is the micro-sequencer to control the opencore_I2C
	----------------------------------------------------------------

	process(reset_n, clk)begin
		if(reset_n = '0')then
			CS <= S_init_1;
		elsif(clk'event and clk = '1')then
			case CS is
			when IDL =>
				mstr_en_n <= '1';
				mstr_read_n <= '1';
				mstr_write_n <= '1';
				mstr_data_out <= (others => '0'); -- don't care
				data_mon <= mstr_data_in(7 downto 0);
				process_done_int <= '0';
				if (command_r_n_d = '0')then
					CS <= S_read_1;
				elsif (command_w_n_d = '0') then
					CS <= S_write_1;
				else
					CS <= IDL;
				end if;
				
			when S_init_1 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"02";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"00";					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_init_2;
				end if;
			when S_init_2 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"01";					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_init_3;
				end if;
			when S_init_3 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"00";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"63"; -- lower 8 bits of the prescale
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_init_4;
				end if;
			when S_init_4 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"01";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"00";					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_init_5;
				end if;
			when S_init_5 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"02";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"80";					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= IDL;
				end if;
				
				
			when S_read_1 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= dev_address(6 downto 0) & '0';					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_2;
				end if;
			when S_read_2 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"90";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_3;
				end if;
			when S_read_3 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_read_4;
					else
						CS <= S_read_3;
					end if;
				end if;
			when S_read_4 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= reg_add;
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_5;
				end if;
			when S_read_5 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"10";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_6;
				end if;
			when S_read_6 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_read_7;
					else
						CS <= S_read_6;
					end if;
				end if;
			when S_read_7 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= dev_address(6 downto 0) & '1';
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_8;
				end if;
			when S_read_8 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"90";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_9;
				end if;
			when S_read_9 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_read_10;
					else
						CS <= S_read_9;
					end if;
				end if;			
			when S_read_10 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"68";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_read_11;
				end if;
			when S_read_11 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_read_12;
					else
						CS <= S_read_11;
					end if;
				end if;			
			when S_read_12 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_read_n <= '1';
					CS <= IDL;
					process_done_int <= '1';
					slv_data_out_int(7 downto 0) <= mstr_data_in(7 downto 0);
				end if;
				
				
				
				
			when S_write_1 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= dev_address(6 downto 0) & '0';					
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_2;
				end if;
			when S_write_2 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"90";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_3;
				end if;
			when S_write_3 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_write_4;
					else
						CS <= S_write_3;
					end if;
				end if;
			when S_write_4 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= reg_add;
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_5;
				end if;
			when S_write_5 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"10";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_6;
				end if;
			when S_write_6 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= S_write_7;
					else
						CS <= S_write_6;
					end if;
				end if;
			when S_write_7 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"03";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= write_data;
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_8;
				end if;
			when S_write_8 =>
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '0';
				mstr_read_n <= '1';
				mstr_data_out(7 downto 0) <= x"50";
				if (mstr_waitrequest_n = '1') then
					mstr_en_n <= '1';
					mstr_write_n <= '1';
					CS <= S_write_9;
				end if;
			when S_write_9 =>  
				mstr_en_n <= '0';
				mstr_address(9 downto 2) <= x"04";
				mstr_write_n <= '1';
				mstr_read_n <= '0';
				mstr_data_out(7 downto 0) <= x"00";
				if (mstr_waitrequest_n = '1') then
					if(mstr_data_in(1) = '0')then
						mstr_en_n <= '1';
						mstr_read_n <= '1';
						CS <= IDL;
						process_done_int <= '1';
					else
						CS <= S_write_9;
					end if;
				end if;			
				
			when others =>
				CS <= IDL;
			end case;
		end if;
	end process; -- End COMB_PROC 
	


	
end rtl;
