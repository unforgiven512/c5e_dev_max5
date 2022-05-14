library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

						
entity i2c_cont is
	port (
		clk: in std_logic; -- system 50MHz clk
		reset : in std_logic; -- system reset/power on reset
		clk_pls_n: in std_logic; -- negative slow clk pulse, less than 100kHz, this project is 50kHz, 1 cycle width of system clk
		clk_pls_p: in std_logic; -- positive slow clk pulse, less than 100kHz, this project is 50kHz, 1 cycle width of system clk
		slow_clk : in std_logic; -- 50kHz clk to output as smb_clk
		
		smb_clk : out std_logic; -- I2C bus control clk
		smb_data : inout std_logic; -- bidirectional data signal

		control_gui : in std_logic_vector(7 downto 0); -- signal as GUI control [5] 0:remote temp  1:local temp
		data_out_t_r : out std_logic_vector(7 downto 0); -- decoded temp data remote
		data_out_t_l : out std_logic_vector(7 downto 0); -- decoded temp data local
		data_out_v : out std_logic_vector(15 downto 0) -- decoded temp data
--		data_out_v12 : out std_logic_vector(15 downto 0) -- decoded temp data
	);
end i2c_cont;

architecture rtl of i2c_cont is
--------------------------------------------------------------------------
	-- address of this I2C target device
	-- for max1619, see page 15 table 9
	constant address_t : std_logic_vector(6 downto 0):="1001100"; -- 0x4C

	-- setting config data
	constant conf_add : std_logic_vector(7 downto 0):="00001001"; --0x09
	constant conf_data : std_logic_vector(7 downto 0):="00101100"; -- 2C as data active-hi
	
	-- setting hysteresis lower limit
	constant hyst_add : std_logic_vector(7 downto 0):="00010011"; --0x13
--	constant hyst_data : std_logic_vector(7 downto 0):="00100100"; -- 36C as lower hys limit
	constant hyst_data : std_logic_vector(7 downto 0):="00101101"; -- 45C as lower hys limit
	
	-- setting the upper limit temp
	constant limit_add : std_logic_vector(7 downto 0):="00010010"; --0x12
--	constant limit_data : std_logic_vector(7 downto 0):="00101000"; -- 40C
	constant limit_data : std_logic_vector(7 downto 0):="00111100"; -- 60C
	
	-- setting the read reg. 0x00 is local temp, 0x01 is the remote temp
	constant remote_add : std_logic_vector(7 downto 0):="00000001"; -- 0x01
	constant remote_data : std_logic_vector(7 downto 0):="00000000"; --0x00
	
	constant local_add : std_logic_vector(7 downto 0):="00000000"; -- 0x00
	
--	constant address_v : std_logic_vector(6 downto 0):="1100111"; -- address for voltage sense
	constant address_v : std_logic_vector(6 downto 0):="1001110"; -- address for voltage sense  0x9C
	-- setting config data
	constant conf_add_v : std_logic_vector(7 downto 0):="00000000";
	constant conf_data_v : std_logic_vector(7 downto 0):="00000000";
	
--------------------------------------------------------------------------

	
	signal address : std_logic_vector(6 downto 0):="1001100"; -- 0x4C
	signal data_out : std_logic_vector(7 downto 0);
	signal data_out_rw : std_logic_vector(7 downto 0);
	signal counter : integer range 0 to 15; -- state machine 1:set hysteresis  2:set upper limit  3:set read reg  4:set config  5:start reading(loop here)
	signal data_cont : std_logic; -- data output control signal, 0:hi-z output  1:output data from this device
	
--	signal read_cnt, write_cnt, read_write_cnt : std_logic; -- enable/disable sub-function  0:disable  1:enable
	signal write_cnt, read_write_cnt : std_logic; -- enable/disable sub-function  0:disable  1:enable

	signal smb_clk_out_r, smb_clk_out_w, smb_clk_out_rw : std_logic; -- smb_clk. during write, select _w. During read, select _r.
	signal smb_data_out_r, smb_data_out_w, smb_data_out_rw : std_logic; -- smb_data. during write, select _w. During read, select _r.
	signal data_cont_r, data_cont_w, data_cont_rw : std_logic; -- data output control signal. during write, select _w. During read, select _r.
	signal send_cmd : std_logic_vector(7 downto 0); -- command value
	signal send_data : std_logic_vector(7 downto 0); -- write data value
	signal write_done : std_logic; -- write process done signal 0:under process  1:process has done
	signal read_done : std_logic; -- read process done signal 0:under process  1:process has done
	signal read_write_done : std_logic; -- read process done signal 0:under process  1:process has done
	signal smb_data_out : std_logic; -- smb_data shared with read/write sub-functions
	signal short_write : std_logic; -- enable short write sequence, used to send only cmd value 0: regular sequence  1:short sequence

	signal gui_control_d : std_logic; -- 1 clk shifted gui_control signal
	signal sel_trig : std_logic; -- edge detection of gui_control signal 0: no edge   1: edge detected
	signal remote_local_sel_int : std_logic; -- after selected remote/local selection
	signal remote_local_sel_intd : std_logic; -- delyed signal
	signal reset_int : std_logic; -- internal use reset, include remote/local change
	
	
	signal data_out_msb : std_logic_vector(7 downto 0);
	signal v_data_msb : std_logic_vector(7 downto 0);
	
	signal start_timer, timeout : std_logic;
	

	component i2c_write
		port(
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
	end component;
	
	component count
		port (
			reset_n: in std_logic;
			clk : in std_logic;
			clk_pls_p : in std_logic; --20us
		
			timeout : out std_logic
		);
	end component;

	component i2c_write_read
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
	end component;

	component issp is
		port (
			probe: in std_logic_vector(15 downto 0);
			source: out std_logic
		);
	end component;	
	signal probe : std_logic_vector(15 downto 0);
	
begin

--	data_out_t_r(15 downto 8) <= "00000000";
--	data_out_t_l(15 downto 8) <= "00000000";
--	data_out_v(3 downto 0) <= "0000";
--	data_out_v12(3 downto 0) <= "0000";

		
	write_data : i2c_write  port map (
		clk, write_cnt, clk_pls_n, clk_pls_p, slow_clk, address, --inputs
		smb_data, smb_clk_out_w, smb_data_out_w, data_cont_w,
--		short_write, send_cmd, send_data, 
		'0', send_cmd, send_data, 
		write_done);

	timer : count port map(
		start_timer, clk, clk_pls_p, timeout
	);

	read_write_data : i2c_write_read  port map (
		clk, read_write_cnt, clk_pls_n, clk_pls_p, slow_clk, address, --inputs
		smb_data, smb_clk_out_rw, smb_data_out_rw, data_cont_rw,
		data_out_rw, send_cmd, send_data, 
		read_write_done);

	-- data can go out only when data_cont is '1'
	-- when data_cont is 0, which is reading data from lm95235
	-- when it is reading data, it needs to tri-state
	process(data_cont, smb_data_out, reset)begin
		if(reset = '0')then
			smb_data <= 'Z';
		elsif(data_cont = '1')then
			smb_data <= smb_data_out;
		else
			smb_data <= 'Z';
		end if;
	end process;

	remote_local_sel_int <= control_gui(5);

	process(clk)begin
		if(clk'event and clk = '1')then
			remote_local_sel_intd <= remote_local_sel_int;
		end if;
	end process;

	reset_int <= reset and (remote_local_sel_int xnor remote_local_sel_intd);

	-- state 1 through 3 is only executed right after reset.
	-- after the state 3, state remain in state4 and loop in state 4.
	process(clk, reset_int)begin
		if(reset_int = '0')then
			counter <= 1;
			write_cnt <= '0';
--			short_write <= '0';
			data_cont <= '0';
			address <= address_t;
			start_timer <= '0';
			smb_clk <= 'Z';
		elsif(clk'event and clk = '1')then
			case counter is

			-- state 1 is to set hysteresis lower limit
			when 1 =>
				write_cnt <= '1';
				send_cmd <= hyst_add;
				send_data <= hyst_data;
				smb_clk <= smb_clk_out_w;
				smb_data_out <= smb_data_out_w;
				data_cont <= data_cont_w;
				if(write_done = '1')then -- when write process done,
					counter <= counter + 1; -- go to next state and set next data
					write_cnt <= '0'; -- reset the write function
				end if;

			-- state 2 is to set max temp limit
			when 2 =>
				write_cnt <= '1';
				send_cmd <= limit_add;
				send_data <= limit_data;
				smb_clk <= smb_clk_out_w;
				smb_data_out <= smb_data_out_w;
				data_cont <= data_cont_w;
				if(write_done = '1')then
					counter <= counter + 1; -- go to next state and set next data
					write_cnt <= '0';
				end if;

			-- state 3 is to set controll register on 2990
			when 3 =>
				address <= address_v;
				write_cnt <= '1';
				send_cmd <= "00000001";
				send_data <= "00011110"; --V1-V2
				smb_clk <= smb_clk_out_w;
				smb_data_out <= smb_data_out_w;
				data_cont <= data_cont_w;
				if(write_done = '1')then -- when write process done,
					counter <= counter + 1; -- go to next state and set next data
					write_cnt <= '0'; -- reset the write function
				end if;
			
			-- state 4 is to set start bit on 2990
			when 4 =>			
				address <= address_v;
				write_cnt <= '1';
				send_cmd <= "00000010";
				send_data <= "00000000"; -- any value is fine
				smb_clk <= smb_clk_out_w;
				smb_data_out <= smb_data_out_w;
				data_cont <= data_cont_w;
				if(write_done = '1')then -- when write process done,
--					counter <= counter + 1; -- go to next state and set next data
					counter <= 7; -- go to next state and set next data
					write_cnt <= '0'; -- reset the write function
				end if;
				
				

			-- start reading temp data
			when 7 =>
				address <= address_t;
				read_write_cnt <= '1';
				send_cmd <= remote_add;
				send_data <= x"00"; -- dummy data
				smb_clk <= smb_clk_out_rw;
				smb_data_out <= smb_data_out_rw;
				data_cont <= data_cont_rw;
				if(read_write_done = '1')then
					counter <= counter + 1;
					read_write_cnt <= '0';
					data_out_t_r(7 downto 0) <= data_out_rw(7 downto 0);
				end if;
				
			when 8 =>
				address <= address_t;
				read_write_cnt <= '1';
				send_cmd <= local_add;			
				send_data <= x"00"; -- dummy data
				smb_clk <= smb_clk_out_rw;
				smb_data_out <= smb_data_out_rw;
				data_cont <= data_cont_rw;
				if(read_write_done = '1')then
--					counter <= 10;
					counter <= counter + 1;
					read_write_cnt <= '0';
					data_out_t_l(7 downto 0) <= data_out_rw(7 downto 0);
				end if;
				
				
			-- state 5 is to read voltage MSB data
			when 9 =>
				address <= address_v;
				read_write_cnt <= '1';
				send_cmd <= "00000110";
				send_data <= x"00"; -- dummy data
				smb_clk <= smb_clk_out_rw;
				smb_data_out <= smb_data_out_rw;
				data_cont <= data_cont_rw;
				if(read_write_done = '1')then
					counter <= counter + 1;
					read_write_cnt <= '0';
					data_out_v(15 downto 8) <= data_out_rw(7 downto 0);
				end if;
			when 10 => -- reading LSB data
				address <= address_v;
				read_write_cnt <= '1';
				send_cmd <= "00000111";
				send_data <= x"00"; -- dummy data
				smb_clk <= smb_clk_out_rw;
				smb_data_out <= smb_data_out_rw;
				data_cont <= data_cont_rw;
				if(read_write_done = '1')then
					counter <= counter + 1;
					read_write_cnt <= '0';
					data_out_v(7 downto 0) <= data_out_rw(7 downto 0);
				end if;


			when 11 => --waiting for 100ms
				start_timer <= '1';
				if(timeout = '1')then
					start_timer <= '0';
					counter <= 7;
				end if;
				
			when others =>
			end case;
		end if;
	end process;
	
end rtl;

