library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fan_cont is
	port(
		reset_n: in std_logic;
		clk : in std_logic;
		clk_pls_p : in std_logic;
		data_out_t_r : in std_logic_vector(7 downto 0);
		fan_cont_out: out std_logic
	);
end fan_cont;


architecture rtl of fan_cont is	
--	signal counter : integer range 0 to 8191;
	signal counter : integer range 0 to 511;
--	signal speed : integer range 0 to 8191;
	signal speed : integer range 0 to 511;
	signal sp : integer range 0 to 15;
	signal temp : integer range 0 to 127;
	signal sp_int : std_logic_vector(3 downto 0);

	constant fan_speed_overwrite : std_logic := '0';
	constant fan_force_on : std_logic := '1';			-- not force on
	constant fan_force_on_fpga : std_logic := '1';		-- not force on

	begin

		temp <= conv_integer(unsigned(data_out_t_r(6 downto 0)));

		process(temp)
		begin
			if (temp > 62) then
				sp <= 15;
				speed <= 511;
--			elsif (temp > 60) then
--				sp <= 14;
--				speed <= 479;
--			elsif (temp > 58) then
--				sp <= 13;
--				speed <= 447;
--			elsif (temp > 56) then
--				sp <= 12;
--				speed <= 415;
--			elsif (temp > 54) then
--				sp <= 11;
--				speed <= 383;
--			elsif (temp > 52) then
--				sp <= 10;
--				speed <= 351;
			elsif (temp > 50) then
				sp <= 9;
				speed <= 319;
--			elsif (temp > 48) then
--				sp <= 8;
--				speed <= 287;
--			elsif (temp > 46) then
--				sp <= 7;
--				speed <= 255;
--			elsif (temp > 44) then
--				sp <= 6;
--				speed <= 223;
--			elsif (temp > 42) then
--				sp <= 5;
--				speed <= 191;
			elsif (temp > 40) then
				sp <= 4;
				speed <= 159;
--			elsif (temp > 38) then
--				sp <= 3;
--				speed <= 127;
--			elsif (temp > 36) then
			elsif (temp > 20) then
				sp <= 2;
				speed <= 95;
			else
--				sp <= 1;
--				speed <= 1023;
				sp <= 2;
				speed <= 95;
			end if;
		end process;


		process(reset_n, clk)
		begin
			if (reset_n = '0') then
				counter <= 0;
			elsif (clk'event and clk = '1') then
				if (clk_pls_p = '1') then
--					if (sp > 1) then
						if (counter = 511) then			-- faster freq
							counter <= 0;
						else
							counter <= counter + 1;
						end if;
--					else
--						if (counter = 8191) then		-- much slower freq
--							counter <= 0;
--						else
--							counter <= counter + 1;
--						end if;
--					end if;
				end if;
			end if;
		end process;


		process(reset_n, clk)
		begin
			if (reset_n = '0') then
				fan_cont_out <= '1';		-- fan off
			elsif (clk'event and clk = '1') then
				if (counter > speed) then
					fan_cont_out <= '1';	-- fan off
				else
					fan_cont_out <= '0';	-- fan on
				end if;
			end if;
		end process;

end rtl;
