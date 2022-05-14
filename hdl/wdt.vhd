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

entity wdt is
	port 
	(
		clk: in std_logic;
		reset_n : in std_logic;
		fpga_conf_done : in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		
		reset: out std_logic := '0'
	);
end wdt;


architecture rtl of wdt is
	-- in PS with 50MHz takes 50334840 clock cycle to configure C3LS200 device
--	signal ctr: integer range 0 to 151000000 := 0;
	signal ctr: integer range 0 to 147460 := 0;
--	signal wait_after_conf_done : integer range 0 to 32500 :=0; -- wait for 650us after conf_done goes high
	signal wait_after_conf_done : integer range 0 to 32 :=0; -- wait for 650us after conf_done goes high
	signal reset_int : std_logic;
	
	signal POC : std_logic:='0'; -- power on clear
	


begin


	process(reset_n, clk)begin
		if(reset_n = '0')then
			ctr <= 0;
			reset_int <= '1';
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
	--			if(wait_after_conf_done = 32500)then
				if(wait_after_conf_done = 32)then
					reset_int <= '0';
	--				ctr <= 151000000;
					ctr <= 147460;
	--			elsif(ctr = 151000000)then
				elsif(ctr = 147460)then
					reset_int <= '0';
					ctr <= ctr;
				else
					reset_int <= '1';
					ctr <= ctr + 1;
				end if;
			end if;
		end if;
	end process;

	reset <= reset_int;

	process(clk, reset_n)begin
		if(reset_n = '0')then
			wait_after_conf_done <= 0;
		elsif(clk'event and clk = '1')then
			if(clk_pls_p = '1')then
				if(fpga_conf_done = '1' and POC = '0')then
					POC <= '1';
	--				if(wait_after_conf_done = 32500)then
					if(wait_after_conf_done = 32)then
						wait_after_conf_done <= wait_after_conf_done;
					else
						wait_after_conf_done <= wait_after_conf_done + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

end rtl;