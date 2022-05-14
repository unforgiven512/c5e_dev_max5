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

entity pwoer_up_counter is
	port 
	(
		reset_n : in std_logic;
		clk: in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		fpga_conf_done : in std_logic;
		
		count_done: out std_logic := '1'
	);
end pwoer_up_counter;


architecture rtl of pwoer_up_counter is
	constant max_val : integer:= 151000;
	signal ctr: integer range 0 to max_val := 0;
	signal wait_after_conf_done : integer range 0 to 32 :=0; -- wait for 650us after conf_done goes high
begin

	process(reset_n, clk)begin
		if(reset_n = '0')then
			count_done <= '1';
			ctr <= 0;
		elsif(clk'event and clk = '1')then
			if(wait_after_conf_done = 32)then
				count_done <= '0';
				ctr <= max_val;
			elsif(clk_pls_p ='1')then
				if(ctr = max_val)then
					count_done <= '0';
					ctr <= ctr;
				else
					count_done <= '1';
					ctr <= ctr + 1;
				end if;
			end if;
		end if;
	end process;

	process(reset_n, clk)begin
		if(reset_n = '0')then
			wait_after_conf_done <= 0;
		elsif(clk'event and clk = '1')then
			if(fpga_conf_done = '1')then
				if(wait_after_conf_done = 32)then
					wait_after_conf_done <= wait_after_conf_done;
				else
					wait_after_conf_done <= wait_after_conf_done + 1;
				end if;
			end if;
		end if;
	end process;

end rtl;