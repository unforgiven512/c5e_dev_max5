library ieee;
use ieee.std_logic_1164.all;

entity err_led is
	port 
	(
		reset_n : in std_logic;
		clk : in std_logic;
		pfl_en : in std_logic;
		conf_done : in std_logic;
		error_led: out std_logic
	);
end err_led;


architecture rtl of err_led is
	signal pfl_en_d1, pfl_en_d2 : std_logic;
	signal pfl_en_raise, pfl_en_fall : std_logic;
begin
	
	process(clk)begin
		if(clk'event and clk = '1')then
			pfl_en_d1 <= pfl_en;
			pfl_en_d2 <= not pfl_en_d1;
		end if;
	end process;
	
	pfl_en_fall <= pfl_en_d1 nor pfl_en_d2;
	pfl_en_raise <= pfl_en and pfl_en_d1;
	
	process(reset_n, clk)begin
		if(reset_n = '0')then
			error_led <= '1';
		elsif(clk'event and clk = '1')then
			if(pfl_en_raise = '1')then
				error_led <= '1';
			elsif(pfl_en_fall = '1')then
				if(conf_done = '0')then
					error_led <= '0';
				else
					error_led <= '1';			
				end if;
			end if;
		end if;
	end process;
	
end rtl;
