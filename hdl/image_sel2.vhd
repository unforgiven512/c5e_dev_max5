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

entity image_sel2 is
	port 
	(
		reset_n : in std_logic;
		clk_50: in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		
		
		image_sel : in std_logic;
		factory_user : in std_logic; -- 0:factory  1:no pfl in C3LS
		count_done : in std_logic;
		pfl_en : in std_logic; -- if this signal is '1' then do not change the selection.
		pfl_pgm : in std_logic_vector(2 downto 0);
		
		image_led : out std_logic_vector(2 downto 0);
		max_factory : out std_logic;
		fpga_pgm : out std_logic_vector(2 downto 0)
	);
end image_sel2;


architecture rtl of image_sel2 is
	signal count : std_logic_vector(1 downto 0);
--	signal timer : integer range 0 to 2097151;
	signal timer : integer range 0 to 2047;
	signal push, push_int1, push_int2 : std_logic;
	signal fpga_pgm_int : std_logic_vector(2 downto 0);
begin
	
	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			timer <= 0;
		elsif(clk_50'event and clk_50 = '1')then
			if(clk_pls_p = '1')then
	--			if(timer = 2097151)then
				if(timer = 2047)then
					timer <= 0;
				else
					timer <= timer + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			push_int1 <= '1';
		elsif(clk_50'event and clk_50 = '1')then
--			if(timer = 2097151)then
			if(timer = 2047)then
				push_int1 <= image_sel;
			end if;
		end if;
	end process;
	
	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			push_int2 <= '0';
		elsif(clk_50'event and clk_50 = '1')then
			push_int2 <= not push_int1;
			push <= push_int1 nor push_int2;
		end if;
	end process;
	

	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			count <= "00";
		elsif(clk_50'event and clk_50 = '1')then
			if(count_done = '1')then
				count(0) <= factory_user;
			elsif(push = '1')then
				if(count = "10")then
					count <= "00";
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;


	process(reset_n, clk_50)begin
		if(reset_n = '0')then
			fpga_pgm_int <= "000";
		elsif(clk_50'event and clk_50 = '1')then
			case count is
			when "00" =>
				fpga_pgm_int <= "000";
			when "01" =>
				fpga_pgm_int <= "001";
			when "10" =>
				fpga_pgm_int <= "010";
			when "11" =>
				fpga_pgm_int <= "011";
			end case;
		end if;
	end process;



	process(reset_n, clk_50)begin
		if(reset_n = '0')then
				image_led <= "111";
				max_factory <= '0';		
		elsif(clk_50'event and clk_50 = '1')then
			case pfl_pgm is
			when "000" =>
				image_led <= "110";
				max_factory <= '0';
			when "001" =>
				image_led <= "101";
				max_factory <= '1';
			when "010" =>
				image_led <= "011";
				max_factory <= '1';
			when others => 
				image_led <= "111";
				max_factory <= '1';
			end case;
		end if;
	end process;
	
	fpga_pgm <= fpga_pgm_int;

end rtl;