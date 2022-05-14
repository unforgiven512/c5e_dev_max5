library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity conf_sel is 
        port (
              -- inputs:
				signal sel : in std_logic;

				signal data_in_a : in STD_LOGIC_VECTOR (15 DOWNTO 0);
				signal clk_in_a : in std_logic;
				signal nConfig_in_a : in std_logic;

				signal data_in_b : in STD_LOGIC_VECTOR (15 DOWNTO 0);
				signal clk_in_b : in std_logic;
				signal nConfig_in_b : in std_logic;
				
                 
              -- outputs:
				signal data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
				signal clk_out : out std_logic;
				signal nConfig_out : out std_logic
              );
end entity conf_sel;


architecture rtl of conf_sel is
begin


	process(sel, data_in_a, clk_in_a ,nConfig_in_a, data_in_b, clk_in_b ,nConfig_in_b)begin
		if(sel = '1')then
			data_out <= data_in_a;
			clk_out <= clk_in_a;
			nConfig_out <= nConfig_in_a;
		else
			data_out <= data_in_b;
			clk_out <= clk_in_b;
			nConfig_out <= nConfig_in_b;
		end if;
	end process;

end rtl;

