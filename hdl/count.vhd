library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

entity count is
	port (
		reset_n: in std_logic;
		clk : in std_logic;
		clk_pls_p : in std_logic; --20us

		timeout : out std_logic
	);
end count;


architecture rtl of count is

	constant max_range : integer := 2500; --50ms with 20us pls
	signal counter : integer range 0 to max_range; 
begin

	process(reset_n, clk)begin
		if(reset_n = '0')then
			counter <= 0;
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
				if(counter = max_range)then
					counter <= counter;
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(reset_n, clk)begin
		if(reset_n = '0')then
			timeout <= '0';			
		elsif(clk'event and clk = '1')then
			if(counter = max_range)then
				timeout <= '1';
			end if;
		end if;
	end process;
end rtl;
