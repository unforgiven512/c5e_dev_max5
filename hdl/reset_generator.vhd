library ieee;
use ieee.std_logic_1164.all;

entity reset_generator is
	port 
	(
		clk: in std_logic;
		reset_in : in std_logic;
		reset: out std_logic
	);
end reset_generator;


architecture rtl of reset_generator is
	signal ctr: integer range 0 to 31 := 0;
begin

	process(clk, reset_in)begin
		if(reset_in = '0')then
			ctr <= 0;
			reset <= '0';
		elsif(rising_edge(clk))then
			if(ctr = 31)then
				reset <= '1';
				ctr <= ctr;
			elsif(ctr > 28)then
				reset <= '0';
				ctr <= ctr + 1;
			else
				reset <= '1';
				ctr <= ctr + 1;
			end if;
		end if;
	end process;
end rtl;