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

entity pfl_control is
	port (
		fpga_conf_done : in std_logic;
		fpga_nstatus : inout std_logic;
		clk_50 : in std_logic;
		clk_config : in std_logic;

		load_image : in std_logic;
		factory_user : in std_logic:='1';
		pgm_sel : in std_logic;
		error_led : out std_logic;

		fsm_d : inout std_logic_vector(15 downto 0);
		fsm_a : out std_logic_vector(24 downto 0);
		flash_cen : out std_logic;
		flash_wen : out std_logic;
		flash_oen : out std_logic;
		flash_clk : out std_logic;
		flash_advn : out std_logic;
		flash_resetn : out std_logic;

		fpga_config_d : out std_logic_vector(15 downto 0);
		fpga_dclk : out std_logic;
		fpga_nconfig : out std_logic;

		reset_n : in std_logic;
		srst : in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		pgm_led : out std_logic_vector(2 downto 0);
		pfl_en_out : out std_logic;
		pfl_pagesel_in : in std_logic_vector(2 downto 0);
		
		
--		security_mode 		: in std_logic;--			//2.5V DIPSWITCH
--		m570_clock 			: out std_logic;--		//2.5V
--		factory_request	: out std_logic;-- := '0';--		//2.5V
--		factory_status 	: in std_logic;--			//2.5V
		
		pcie_jtag_en		: in std_logic--			//2.5V DIPSWITCH
--		m570_pcie_jtag_en	: out std_logic--			//2.5V
		
		
	);
end pfl_control;


architecture rtl of pfl_control is
	COMPONENT p2 IS
		PORT
		(
			fpga_conf_done					: IN STD_LOGIC ;
			fpga_nstatus					: IN STD_LOGIC ;
			fpga_pgm							: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			pfl_clk							: IN STD_LOGIC ;
			pfl_flash_access_granted	: IN STD_LOGIC ;
			pfl_nreconfigure				: IN STD_LOGIC  := '1';
			pfl_nreset						: IN STD_LOGIC ;
			flash_addr						: OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
			flash_clk						: OUT STD_LOGIC ;
			flash_data						: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			flash_nadv						: OUT STD_LOGIC ;
			flash_nce						: OUT STD_LOGIC;
			flash_noe						: OUT STD_LOGIC ;
			flash_nreset					: OUT STD_LOGIC ;
			flash_nwe						: OUT STD_LOGIC ;
			fpga_data						: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			fpga_dclk						: OUT STD_LOGIC ;
			fpga_nconfig					: OUT STD_LOGIC ;
			pfl_flash_access_request	: OUT STD_LOGIC 
		);
	END COMPONENT;	signal pfl_nConfig_int : std_logic;

	signal fl_access_req : std_logic;
	signal flash_cen_int : std_logic;
	
	COMPONENT wdt port (
		clk: in std_logic;
		reset_n : in std_logic;
		fpga_conf_done : in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		reset: out std_logic
	);
	end COMPONENT;
	
	signal reconfigure_n : std_logic;
	
	COMPONENT reset_pls port (
			clk: in std_logic;
			pls_out: out std_logic
		);
	end COMPONENT;	
	signal pls_out : std_logic;
	signal pfl_en : std_logic;
	
	COMPONENT image_sel2 port (
			reset_n : in std_logic;
			clk_50: in std_logic;
			clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
			
			image_sel : in std_logic;
			factory_user : in std_logic; -- 0:factory  1:no pfl in C3LS
			count_done : in std_logic;
			pfl_en : in std_logic;
			pfl_pgm : in std_logic_vector(2 downto 0);
			
			image_led : out std_logic_vector(2 downto 0);
			max_factory : out std_logic;
			fpga_pgm : out std_logic_vector(2 downto 0)
		);
	end COMPONENT;
	
	signal conf_done1, conf_done2 : std_logic;
	signal fpga_pgm : std_logic_vector(2 downto 0);

	COMPONENT pwoer_up_counter is
		port 
		(
			reset_n : in std_logic;
			clk: in std_logic;
			clk_pls_p: in std_logic;
			fpga_conf_done : in std_logic;
			count_done: out std_logic := '0'
		);
	end COMPONENT;	
	signal count_done : std_logic := '1';
	signal pfl_pagesel_int : std_logic_vector(2 downto 0) := "000";
	signal pfl_pagesel : std_logic_vector(2 downto 0) := "000";

	COMPONENT err_led is
		port 
		(
			reset_n : in std_logic;
			clk : in std_logic;
			pfl_en : in std_logic;
			conf_done : in std_logic;
			error_led: out std_logic
		);
	end COMPONENT;

--This is for FPPoVJ	
	COMPONENT rbfOvj port (
		system_clk : in std_logic;
		reset_n : in std_logic;
		fpga_nstatus : IN STD_LOGIC;
		data_out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		clk_out_port : out std_logic;
		nConfig_out_port : out std_logic
    );
	end COMPONENT;
	
	signal pfl_data : std_logic_vector(15 downto 0);
	signal pfl_dclk : std_logic;
	signal pfl_nConfig : std_logic;
	signal rbfOvj_data : std_logic_vector(15 downto 0);
	signal rbfOvj_dclk : std_logic;
	signal rbfOvj_nConfig : std_logic;

--This is for FPPoVJ	
	COMPONENT conf_sel port (
		sel : in std_logic;
		data_in_a : in STD_LOGIC_VECTOR (15 DOWNTO 0);
		clk_in_a : in std_logic;
		nConfig_in_a : in std_logic;
		data_in_b : in STD_LOGIC_VECTOR (15 DOWNTO 0);
		clk_in_b : in std_logic;
		nConfig_in_b : in std_logic;			
		data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		clk_out : out std_logic;
		nConfig_out : out std_logic
	);
	end COMPONENT;

	
	COMPONENT factory_control is
		port (
			reset_n : in std_logic;
			clk_50 : in std_logic;
			clk_pls_p : in std_logic;
			
			fpga_nstatus : inout std_logic;
--			security_mode 		: in std_logic;
--			m570_clock 			: out std_logic;
--			factory_request	: out std_logic;
--			factory_status 	: in std_logic;
			
			pcie_jtag_en		: in std_logic;
--			m570_pcie_jtag_en	: out std_logic;
			
			pfl_start_mask		: out std_logic;
			pfl_start_pls_n	: out std_logic
			
			
		);
	end COMPONENT;	
	
--	signal m570_clock_int : std_logic;
--	signal m570_clock_en : std_logic;
--	signal factory_request_int : std_logic;	
	signal pfl_start_pls_n : std_logic;
	signal pfl_start_mask : std_logic;


begin

	
	reset_pls_inst : reset_pls port map(clk_50, pls_out);
	
	reconfigure_n <= (load_image and pls_out and reset_n and srst and pfl_start_pls_n) or pfl_start_mask;
	wdt_inst : wdt port map(clk_50, reconfigure_n, fpga_conf_done, clk_pls_p, pfl_en);

	image_sel_inst : image_sel2 port map(
			-- input
			reset_n => reset_n,
			clk_50 => clk_50,
			clk_pls_p => clk_pls_p,
			
			image_sel=> pgm_sel,
			pfl_en => pfl_en,
			pfl_pgm => pfl_pagesel_int, -- current page selection. Used to select LED

			factory_user => factory_user,
			count_done => count_done,
			
			-- output
			image_led => pgm_led, --output
--			max_factory : out std_logic;
			fpga_pgm => fpga_pgm --output  This is same as PageSelectSwitch
	);

	pwoer_up_counter_inst : pwoer_up_counter port map(
			-- input
			reset_n => reset_n,
			clk => clk_50,
			clk_pls_p => clk_pls_p,
			fpga_conf_done => fpga_conf_done,
--			fpga_conf_done => fpga_conf_done_int,
			-- output
			count_done => count_done
		);

		
-- pfl_pagesel_int goes to PFL itself
-- The PowerUp sequence uses the factory_user section only on the pwoer up.
-- After powered up, use either PSS or PSR.  PSS is the default selection	
	process(reset_n, clk_config)begin
		if(reset_n = '0')then
			pfl_pagesel_int <= "00" & factory_user;
		elsif(clk_config'event and clk_config = '1')then
			if(count_done = '1')then
				pfl_pagesel_int <= "00" & factory_user;
			else
				if(pfl_en = '0')then -- set PSS setting as default selection
					pfl_pagesel_int <= fpga_pgm; -- use PSS setting
				elsif(pfl_en = '1' and srst = '0')then -- only if the trigger comes from srst
					pfl_pagesel_int <= pfl_pagesel_in;-- use PSR setting
				end if;
			end if;
		end if;
	end process;

	pfl_x16_inst: p2
	PORT MAP(
		fpga_conf_done => fpga_conf_done,
		fpga_nstatus => fpga_nstatus,
		fpga_pgm => pfl_pagesel_int,
--		fpga_pgm => "00" & factory_user,
		pfl_clk => clk_50,
		pfl_flash_access_granted => fl_access_req and (not fpga_conf_done),
--		pfl_nreconfigure	=> load_image,--pfl_nreconfigure_sig,
		pfl_nreconfigure	=> reconfigure_n,--pfl_nreconfigure_sig,
		pfl_nreset	 => pfl_en,--max_resetn,--
		flash_addr	 => fsm_a,--
		flash_clk	 => flash_clk,--
		flash_data	 => fsm_d,--
		flash_nadv	 => flash_advn,--
		flash_nce	 => flash_cen,--
		flash_noe	 => flash_oen,--
		flash_nreset => flash_resetn,
		flash_nwe	 => flash_wen,--
		fpga_data	 => pfl_data,--
		fpga_dclk	 => pfl_dclk,--
		fpga_nconfig => pfl_nConfig,--
		pfl_flash_access_request	 => fl_access_req--
	);

--	flash_clk <= '0';
--	flash_advn <= '0';
--	flash_resetn <= '1';


	err_led_inst: err_led
	PORT MAP(
		reset_n => reset_n,
		clk => clk_50,
		pfl_en => pfl_en,
		conf_done => fpga_conf_done,
		error_led => error_led
	);

	rbfOvj_inst: rbfOvj
	PORT MAP(
		system_clk => clk_50,
		reset_n => reset_n,
		fpga_nstatus => fpga_nstatus,
		data_out_port => rbfOvj_data,
		clk_out_port => rbfOvj_dclk,
		nConfig_out_port => rbfOvj_nConfig
	);

	conf_sel_inst: conf_sel
	PORT MAP(
		-- selection signal
		sel => pfl_en,    --'1' select a      '0'  select b

		-- pfl input
		data_in_a => pfl_data,
		clk_in_a => pfl_dclk,
		nConfig_in_a => pfl_nConfig,

		-- rbf input
		data_in_b => rbfOvj_data,
		clk_in_b => rbfOvj_dclk,
		nConfig_in_b => rbfOvj_nConfig,

		data_out => fpga_config_d,
		clk_out => fpga_dclk,
		nConfig_out => fpga_nconfig
	);

	-- This function is to unlock the FPGA
	-- mini-max will unlock, but this MAX still needs to control
	factory_control_inst: factory_control
	PORT MAP(
		reset_n => reset_n,
		clk_50 => clk_50,
		clk_pls_p => clk_pls_p,

		fpga_nstatus => fpga_nstatus,
--		security_mode => security_mode,
--		m570_clock => m570_clock,
--		factory_request => factory_request,
--		factory_status => factory_status,

		pcie_jtag_en => pcie_jtag_en,
--		m570_pcie_jtag_en	=> m570_pcie_jtag_en,

		pfl_start_mask => pfl_start_mask,
		pfl_start_pls_n => pfl_start_pls_n
	);

	pfl_en_out <= pfl_en;

end rtl;
