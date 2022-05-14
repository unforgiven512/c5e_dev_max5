-- This is the decoder/controler for LTC2418 chip
-- 2418 require specific interval, which is minimum 136.2ms
-- User need to generate slower clk than 2MHz as operation clock for 2418
-- In this design, SCK was set to 1MHz
-- SCK is set as active(external) SCK mode by using CS signal toggle

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ltc2418_cont is

	port
	(
		reset_n: in std_logic; -- power on reset signal  0:reset   1:normal
		clk : in std_logic; -- system CLK in this board is 50MHz
		sdo_in : in std_logic; -- data comming from 2418
		rail_sel : in std_logic_vector(3 downto 0); -- power rail selection signal from rotaly sw
		
		clk_1M_out : out std_logic; -- this will be the SCK for 2418
		cs_out0 : out std_logic; -- CS for 2418 has to be controlled, due to active SCK control   0:selected  1:not selected
--		cs_out1 : out std_logic; -- CS for 2418 has to be controlled, due to active SCK control   0:selected  1:not selected
		sdi : out std_logic; -- output data for 2418
		dclk : out std_logic; -- in process signal   0:waiting for data   1:this function is in process
		dec_data_out : out std_logic_vector(23 downto 0); -- decoded data
		sgl_out : out std_logic -- 0:differential signal   1:single ended signal
	);

end ltc2418_cont;


architecture rtl of ltc2418_cont is
	
--	constant MAX_COUNT : integer := 49; -- Use this count value to generate 1MHz
	constant MAX_COUNT : integer := 99;
	
	signal counter : integer range 0 to 140063 := 0; -- it has to be bigger than 13620 which is 136.2ms with 100kHz
	signal do_en_int : std_logic; -- SCK output control signal
	signal rx_index, tx_index  : integer;
	signal tx_data : std_logic_vector(6 downto 0) := "0101000"; -- data to transmit to 2418
	signal dec_data : std_logic_vector(31 downto 0);

	signal clk_1M : std_logic; -- used as SCK for 2418
	signal clk_pls_p : std_logic; -- used to sample in comming data from 2418
	signal clk_pls_n : std_logic; -- used to generate transmit data, it has to sync with negative edge

	signal counter_clk : integer range 0 to (MAX_COUNT-1) := 0; -- counter to generate 100kHz from 50MHz
	signal twocycle : std_logic; -- controller for getting both differential and single ended voltage
	constant max_val : integer := 8388607; -- solution for negative input data...
	signal cs_out : std_logic;
	signal cs_change1, cs_change2 : std_logic;
	
	signal clk_pls_p_d1, clk_pls_p_d2 : std_logic;
	signal en : std_logic;
begin

-------------------------
-- CLK control section --
-------------------------

-- counter to generate 50kHz clk from 50MHz system clk	
	process(reset_n, clk)begin
		if(reset_n = '0')then
			counter_clk <= 0;
		elsif(clk'event and clk = '1')then
			if(counter_clk = (MAX_COUNT-1))then
				counter_clk <= 0;
			else
				counter_clk <= counter_clk + 1;
			end if;
		end if;
	end process;

-- generating 1MHz clk, 1MHz positive edge and negative edge pulse.
	process(reset_n, clk)begin
		if(reset_n = '0')then
			clk_1M <= '1';
			clk_pls_p <= '0';
			clk_pls_n <= '0';
		elsif(clk'event and clk = '1')then
			if(counter_clk = (MAX_COUNT/2))then
				clk_1M <= '0';
				clk_pls_p <= '0';
				clk_pls_n <= '1';
			elsif(counter_clk = 0)then
				clk_1M <= '1';
				clk_pls_p <= '1';
				clk_pls_n <= '0';
			else
				clk_pls_p <= '0';
				clk_pls_n <= '0';		
			end if;
		end if;
	end process;	


-------------------------
-- process counter     --
-------------------------
	process(reset_n, clk)begin
		if(reset_n = '0')then
			counter <= 0;
			twocycle <= '0';
		elsif(clk'event and clk = '1')then
			if(clk_pls_n = '1')then
				if(counter = 140063)then
					counter <= 0;
					twocycle <= not twocycle;
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;



-------------------------
-- Tx data controller  --
-------------------------
	-- setting with power rail info to read from
	tx_data(2 downto 0) <= rail_sel(2 downto 0);		
	
	process(reset_n, clk)begin
		if(reset_n = '0')then
		elsif(clk'event and clk = '1')then
			if(twocycle = '0')then
				tx_data(5 downto 3) <= "110";
			else
				tx_data(5 downto 3) <= "101";
			end if;
		end if;
	end process;

	
-------------------------
-- Tx controller       --
-------------------------
	process(reset_n, clk)begin
		if(reset_n = '0')then
			cs_out <= '1';
			do_en_int <= '0';
			sdi <= '0';
		elsif(clk'event and clk = '1')then
			if(clk_pls_n = '1')then
				case counter is
				when 0 =>
					cs_out <= '1';
					do_en_int <= '0';
					sdi <= '0';
				when 140020 =>  -- setting active SCK mode
					cs_out <= '0';
				when 140022 =>  -- setting active SCK mode
					cs_out <= '1';
				when 140032 => -- start sending start sequence from here
					do_en_int <= '1';
					cs_out <= '0';
					sdi <= '1';
					tx_index <= 6;
				when others =>
					if(counter >= 140033 and counter < 140040)then -- sending data
						sdi <= tx_data(tx_index);
						tx_index <= tx_index - 1;
					end if;
				end case;
			end if;
		end if;
	end process;


-------------------------
-- Rx controller       --
-------------------------
	process(reset_n, clk)begin
		if(reset_n = '0')then
			dec_data <= (others => '1');
			rx_index <= 31;
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
				if(counter >= 140033)then -- start receiving data from here
					dec_data(rx_index) <= sdo_in;
					rx_index <= rx_index - 1;
				elsif(counter = 0)then
					dec_data(0) <= sdo_in;
					rx_index <= 31;

					-- temp solution for negative input data... 29th bit is sign bit,  0: negative data  1:positive data
					if(dec_data(29) = '0')then
						dec_data_out(22 downto 0) <= std_logic_vector(conv_unsigned((max_val - conv_integer(unsigned(dec_data(28 downto 6)))),23));
					else
						dec_data_out(22 downto 0) <= dec_data(28 downto 6);
					end if;

				end if;
			end if;
		end if;
	end process;
	
	-- re-timming output
	process(clk)begin
		if(clk'event and clk = '1')then
			clk_1M_out <= clk_1M and do_en_int;
		end if;
	end process;


	dec_data_out(23) <= '0';
	
	process(reset_n, clk)begin
		if(reset_n = '0')then
			clk_pls_p_d1 <= '0';
			clk_pls_p_d2 <= '1';
		elsif(clk'event and clk = '1')then
			clk_pls_p_d1 <= clk_pls_p;
			clk_pls_p_d2 <= not clk_pls_p_d1;
			en <= clk_pls_p_d2 and clk_pls_p_d1;
		end if;
	end process;

	process(reset_n, clk)begin
		if(reset_n = '0')then
			dclk <= '1';
			sgl_out <= '0';
		elsif(clk'event and clk = '1')then
			if(counter = 1 and en = '1')then
				dclk <= '0';
				sgl_out <= dec_data(5);
			else
				dclk <= '1';
			end if;
		end if;
	end process;

	cs_out0 <= cs_out;
	
end rtl;



