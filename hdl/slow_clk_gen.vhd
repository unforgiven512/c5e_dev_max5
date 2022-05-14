library ieee;
use ieee.std_logic_1164.all;

entity slow_clk_gen is
	port (
		clk: in std_logic;
		reset : in std_logic;
		clk_pls_n: out std_logic;
		clk_pls_p: out std_logic;
		clk_pls_p_deley : out std_logic;
		
		slow_clk : out std_logic -- from 50MHz, it will be 48.828KHz or 20.480us
	);
end slow_clk_gen;



architecture rtl of slow_clk_gen is
	
	signal ctr : integer range 0 to 1023;
	signal slow_clk_int : std_logic;
begin
	
	slow_clk <= not slow_clk_int;
	
	process(clk, reset)begin
		if(reset = '0')then
			ctr <= 0;
			slow_clk_int <= '1';
		elsif(clk'event and clk = '1')then
			if(ctr = 1023)then
				slow_clk_int <= not slow_clk_int;
				clk_pls_n <= '1';
				ctr <= 0;
				clk_pls_p <= '0';
			elsif(ctr = 511)then
				slow_clk_int <= not slow_clk_int;
				ctr <= ctr + 1;
				clk_pls_p <= '1';
			elsif(ctr = 289)then
				ctr <= ctr + 1;
				clk_pls_p_deley <= '1';
			else
				clk_pls_n <= '0';
				ctr <= ctr + 1;
				clk_pls_p <= '0';
				clk_pls_p_deley <= '0';
			end if;
		end if;
	end process;
end rtl;