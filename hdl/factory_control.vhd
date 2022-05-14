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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity factory_control is
	port (
		reset_n : in std_logic;
		clk_50 : in std_logic;
		clk_pls_p : in std_logic; --20us interval
		
		fpga_nstatus : inout std_logic;
--		security_mode 		: in std_logic;
--		m570_clock 			: out std_logic;
--		factory_request	: out std_logic;
--		factory_status 	: in std_logic;
		
		pcie_jtag_en		: in std_logic;
--		m570_pcie_jtag_en	: out std_logic;
		
		pfl_start_mask		: out std_logic;
		pfl_start_pls_n	: out std_logic
	);
end factory_control;


architecture rtl of factory_control is
--	signal m570_clock_en : std_logic;
--	signal factory_request_int : std_logic;
--	signal m570_clock_int : std_logic;
	
--	signal wait_counter : integer range 0 to 300000;
	signal wait_counter : integer range 0 to 255;
	signal wait_9ms : integer range 0 to 500;
	signal reset_n_int : std_logic;
begin

	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			reset_n_int <= '0';
		elsif(clk_50'event and clk_50 = '1')then
			if(wait_9ms = 500)then
				reset_n_int <= '1';
			end if;
		end if;
	end process;

	-- counter to count up to more than 9ms of time
	-- only this block needs to use the original reset_n signal
	process(reset_n, clk_50)begin
		if(reset_n = '0')then
				wait_9ms <= 0;
		elsif(clk_50'event and clk_50 = '1')then
			if(clk_pls_p = '1')then
				if(wait_9ms = 500)then
					wait_9ms <= 500;
				else
					wait_9ms <= wait_9ms + 1;
				end if;
			end if;
		end if;
	end process;
	
  -- for the factory command trick ------	
--	process(reset_n_int, clk_50)begin
--		if(reset_n_int = '0')then
--				m570_clock_en <= '0';
--				factory_request_int <= '1';		
--		elsif(clk_50'event and clk_50 = '1')then
--			if(security_mode = '0')then
--				--normal operation
--				m570_clock_en <= '0';
--				factory_request_int <= '1';
--			else
--				--issue the factory command
--				if(factory_status = '0')then -- waiting for the completion of factory command
--					m570_clock_en <= '1';
--					factory_request_int <= '0';
--				else -- stop issuing the command at here
--					m570_clock_en <= '0';
--					factory_request_int <= '1';
--				end if;
--			end if;
--		end if;
--	end process;

	-- generate 25MHz clk to feed mini-max
--	process(reset_n_int, clk_50)begin
--		if(reset_n_int = '0')then
--			m570_clock_int <= '0';
--		elsif(clk_50'event and clk_50 = '1')then
--			if(m570_clock_en = '1')then
--				m570_clock_int <= not m570_clock_int; -- toggle!
--			else
--				m570_clock_int <= '0';
--			end if;
--		end if;
--	end process;
--	m570_clock <= m570_clock_int;
--	m570_pcie_jtag_en <= pcie_jtag_en;

--	process(reset_n_int, m570_clock_int)begin
--		if(reset_n_int = '0')then
--			factory_request <= '1';
--		elsif(m570_clock_int'event and m570_clock_int = '1')then
--			factory_request <= factory_request_int;
--		end if;
--	end process;	

	-- wait for a while after the factory command sequence finished
	process(reset_n_int, clk_50)begin
		if(reset_n_int = '0')then
			wait_counter <= 0;
		elsif(clk_50'event and clk_50 = '1')then
--			if(security_mode = '0' or (factory_status = '1' and fpga_nstatus = '1'))then --either non secure mode or after factory issued
			if(fpga_nstatus = '1')then -- non secure mode
				if(clk_pls_p = '1')then
					if(wait_counter = 255)then --6ms of wait
						wait_counter <= 255;
					else
						wait_counter <= wait_counter + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(reset_n_int, clk_50)begin
		if(reset_n_int = '0')then
			pfl_start_pls_n <= '1';
			pfl_start_mask <= '1';
		elsif(clk_50'event and clk_50 = '1')then
--			if(wait_counter = 300000)then
			if(wait_counter = 255)then
				pfl_start_pls_n <= '1';
				pfl_start_mask <= '0';
--			elsif(wait_counter > 290000)then
			elsif(wait_counter = 250)then
				pfl_start_pls_n <= '0';
				pfl_start_mask <= '0';
--			else
--				pfl_start_pls_n <= '1';
--				pfl_start_mask <= '1';
			end if;
		end if;
	end process;



	process(reset_n_int, clk_50)begin
		if(reset_n_int = '0')then
			fpga_nstatus <= '0';			
		elsif(clk_50'event and clk_50 = '1')then
--			if(security_mode = '0' or factory_status = '1')then
				fpga_nstatus <= 'Z';
--			end if;
		end if;
	end process;
	
end rtl;
