--Legal Notice: (C)2009 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.

library ieee;
use ieee.std_logic_1164.all;

entity reset_pls is
	port 
	(
		clk: in std_logic;
		pls_out: out std_logic :='1'
	);
end reset_pls;


architecture rtl of reset_pls is
	signal ctr: integer range 0 to  1023:= 0;
begin

	process(clk)begin
		if(rising_edge(clk))then
			if(ctr = 1023)then
				pls_out <= '1';
				ctr <= ctr;			
			elsif(ctr >= 30)then
				pls_out <= '0';
				ctr <= ctr + 1;
			else
				pls_out <= '1';
				ctr <= ctr + 1;
			end if;
		end if;
	end process;
end rtl;