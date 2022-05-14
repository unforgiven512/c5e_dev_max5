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
use ieee.std_logic_unsigned.all;


entity fpga_interface is
	port
	(
		--Global signals
		reset_n: in std_logic;
		fsm_clk : in std_logic;
		
		--FPGA interface
		max5_csn: in std_logic;
		max5_wen: in std_logic;
		max5_oen: in std_logic;
		max5_ben : in std_logic_vector(3 downto 0);
		max5_clk : in std_logic;
		
		address: inout std_logic_vector(4 downto 0);
		data: inout std_logic_vector(15 downto 0);
--		max_ben : in std_logic_vector(3 downto 0); -- byte write enable signal
		
		--dipswitch/PFL interface
		dsw_pagesel: in std_logic_vector(3 downto 0);
		pfl_pagesel: out std_logic_vector(2 downto 0);
		srst_out : out std_logic;
		
		-- power and temp data
		diff_raw : in std_logic_vector(23 downto 0);
		single_raw : in std_logic_vector(23 downto 0);
		pfl_en : in std_logic;
		
		-- clk control
--		clk125_en : out std_logic;
--		clk66_en : out std_logic;
--		clk100_en : out std_logic;
--		clk50_en : out std_logic;
--		clk_sel : in std_logic;
--		clk_enable : in std_logic;
		
		-- board setting
		sram_mode : out std_logic;
		sram_zz : out std_logic;
		fan_force_on : out std_logic;
		fan_speed : out std_logic_vector(3 downto 0);
		hsma_orsntn : in std_logic;
		hsmb_orsntn : in std_logic;
		MAX_VER : in std_logic_vector(7 downto 0);
		fan_speed_overwrite : out std_logic;
		factory_confign : in std_logic;
		system_clk : in std_logic		
		
	);

end fpga_interface;


architecture rtl of fpga_interface is
	
	constant REGFILE_TOP: integer := 4;
	type regfile_t is array(1 to REGFILE_TOP) of std_logic_vector(15 downto 0);
	signal regfile: regfile_t;
	
	alias pss is regfile(2)(3 downto 0);
	alias pso is regfile(2)(4);
	alias psr is regfile(2)(10 downto 8);
	alias srst is regfile(2)(11);
		
	signal address_int : std_logic_vector(4 downto 0);
	signal srst_d1, srst_d2 : std_logic;
	
	signal reset_count : integer range 0 to 15;
	signal pfl_pagesel_int : std_logic_vector(2 downto 0);

	signal data_int : std_logic_vector(15 downto 0):=(others => '0');

--component issp IS
--	PORT
--	(
--		probe		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		source		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
--	);
--END component;
--signal srst_hold : std_logic := '1';
	
begin


---------------------------------------------------------------------------------------------------------
-- FPGA interface logic
---------------------------------------------------------------------------------------------------------
--issp_inst : issp PORT map	(
--		probe(4 downto 0) => srst_hold & regfile(2)(11 downto 8)
--	);
	
	prc_regfile:
	process(reset_n,fsm_clk, regfile)begin	
		
		-------------------------------------------------
		--Reset clause
		-------------------------------------------------
		if(reset_n = '0')then
			pso		<= '1';
--			srst <= '1';
			psr <= "111";
			regfile(3)(15 downto 2) <= (others => '1');
			regfile(3)(1) <= '0';
			regfile(3)(0) <= '1';
			regfile(4)(15 downto 0) <= "0000111100111100";
			regfile(4)(15 downto 16) <= (others => '0');
			regfile(2)(15 downto 12) <= (others => '0');
			regfile(2)(7 downto 5) <= "000";
			
		-------------------------------------------------
		--Operating clause
		-------------------------------------------------
		elsif(fsm_clk'event and fsm_clk = '1')then
			if(max5_csn = '0')then
				address_int <= address;
				--Read clause
				if(max5_wen = not('0') and max5_oen = '0')then
				--Write clause
				elsif(max5_wen = '0' and max5_oen = not('0'))then
					case address is
						when "00010" => 
							if(max5_ben(0) = '0')then
							end if;							
							if(max5_ben(1) = '0')then
								regfile(2)(10 downto 8)	<= data(10 downto 8); -- PSR
							end if;
							if(max5_ben(2) = '0')then
								regfile(2)(4)<= data(4); -- PSO
							end if;
							if(max5_ben(3) = '0')then
								regfile(2)(11)		<= data(11); --SRST
							end if;
						when "00011" => regfile(1) <= data(15 downto 0);
						when "00100" => 
							if(max5_ben(0) = '0')then
								regfile(3)(5 downto 0) <= data(5 downto 0);
							end if;							
						when "00101" => 
							if(max5_ben(0) = '0')then
								regfile(4)(5 downto 0) <= data(5 downto 0);
							end if;							
							if(max5_ben(1) = '0')then
								regfile(4)(12 downto 8) <= data(12 downto 8);
							end if;
							if(max5_ben(2) = '0')then
							end if;
							if(max5_ben(3) = '0')then
							end if;
						when others => null;
					end case;
				end if;		
			else
				--srst <= '1'; -- need to clear the re-config request bit
				regfile(2)(11) <= '1';
			end if;
		end if;
	end process;

	srst <= regfile(2)(11);
				

	process(fsm_clk, pfl_en)begin
		if(pfl_en = '1')then
			data <= (others => 'Z');
		elsif(fsm_clk'event and fsm_clk = '1')then
			if(max5_oen = '0' and max5_csn = '0')then
				data <= data_int;
			else
				data <= (others => 'Z');
			end if;
		end if;
	end process;
	
	process(fsm_clk)begin
		if(fsm_clk'event and fsm_clk = '1')then
			case address_int is
				when "00000" => data_int <= x"AC81";  -- 0xAC81 is the unique board p/n (decimal 44161)of the C5E DEV KIT
				when "00001" => data_int <= x"00" & MAX_VER;  -- MAX-V program Rev
				when "00010" => data_int <= regfile(2); -- control reg RSU
				when "00011" => data_int <= regfile(1); -- reserved
				when "00100" => data_int(5 downto 0) <= regfile(3)(5 downto 0); -- clk control reg
--								data(9 downto 8) <= clk_enable & clk_sel;
								data_int(7 downto 6) <= "00";
								data_int(15 downto 10) <= "000000";
				when "00101" => data_int(7 downto 0) <= hsmb_orsntn & hsma_orsntn & regfile(4)(5 downto 0); -- board control reg
								data_int(12 downto 8) <= regfile(4)(12 downto 8);
								data_int(15 downto 11) <= (others => '0');
				when "00110" => data_int(15 downto 0) <= diff_raw(15 downto 0);
				when "00111" => data_int(7 downto 0) <= diff_raw(23 downto 16);
				when "01000" => data_int(15 downto 0) <= single_raw(15 downto 0);
				when "01001" => data_int(7 downto 0) <= single_raw(23 downto 16);
				when others => data_int <= data_int;
			end case;
		end if;
	end process;

---------------------------------------------------------------------------------------------------------
--dipswitch/PFL interface
---------------------------------------------------------------------------------------------------------
	pss <= dsw_pagesel;	
	
	process(reset_n, system_clk)begin	
		if(reset_n = '0')then
			pfl_pagesel_int <= dsw_pagesel(2 downto 0);	
		elsif(system_clk'event and system_clk = '1')then
			if(factory_confign = '0')then
				pfl_pagesel_int <= "000";
			elsif(pfl_en = '1')then -- do not change the pagesel during configuration
				pfl_pagesel_int <= pfl_pagesel_int;
			elsif(pso = '1')then
				pfl_pagesel_int  <= dsw_pagesel(2 downto 0);			
			else
				pfl_pagesel_int  <= psr;				
			end if;
		end if;
	end process;
	pfl_pagesel <= pfl_pagesel_int;

	
	process(reset_n, srst, fsm_clk)begin
		if(reset_n = '0')then
			reset_count <= 15;
		elsif(srst = '0')then
			reset_count <= 0;
		elsif(fsm_clk'event and fsm_clk = '1')then
			if(reset_count = 15)then
				reset_count <= reset_count;
			else
				reset_count <= reset_count + 1;
			end if;
		end if;
	end process;

	process(reset_n, fsm_clk)begin
		if(reset_n = '0')then
			srst_out <= '1';	
		elsif(fsm_clk'event and fsm_clk = '1')then
			if(reset_count = 15)then
				srst_out <= '1';
			else
				srst_out <= '0';			
			end if;
		end if;
	end process;


--	process(reset_n, clk_enable, regfile)begin
--		if(reset_n = '0')then
--			clk125_en <= '1';
--			clk66_en <= '1';
--			clk100_en <= '1';
--			clk50_en <= '1';
--		elsif(clk_enable = '1')then
--			clk125_en <= '0';
--			clk66_en <= '0';
--			clk100_en <= '0';
--			clk50_en <= '1'; -- 50MHz is always on
--		else
--			clk125_en <= regfile(3)(0);
--			clk66_en <= regfile(3)(3);
--			clk100_en <= regfile(3)(4);
--			clk50_en <= '1'; -- 50MHz is always on
--		end if;
--	end process;

	process(reset_n, regfile)begin
		if(reset_n = '0')then
			sram_mode <= '0';
			sram_zz <= '0';
			fan_force_on <= '1';
			fan_speed <= "1111";
			fan_speed_overwrite <= '0';
		else
			sram_mode <= regfile(4)(0);
			sram_zz <= regfile(4)(1);
			fan_force_on <= regfile(4)(5);
			fan_speed(3 downto 0) <= regfile(4)(11 downto 8);
			fan_speed_overwrite <= regfile(4)(12);
		end if;
	end process;

end rtl;

