library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity max5 is
	PORT(
		----------- clk -----------
		clk_config: in std_logic;								-- // 2.5V / 100 MHz
		clkin_50: in std_logic;									-- // 2.5V / 50 MHz, also to FPGA

		----------- clk control -----------
--		clk125_en: out std_logic := '1';						-- // 2.5V
--		clk50_en: out std_logic := '1';							-- // 2.5V, on-board pull up enables 50MHz clock
		si570_en: out std_logic := '1';							-- // 2.5V

		clock_scl: inout std_logic;								-- // 2.5V Programmable clocks I2C serial clock
		clock_sda: inout std_logic;								-- // 2.5V Programmable clocks I2C data bus

		clk_enable: in std_logic;								-- // 2.5V DIPSWITCH
		clk_sel: in std_logic;									-- // 2.5V DIPSWITCH


		----------- fpga ----------- (others => 'Z')
		fpga_config_d: out std_logic_vector(15 downto 0);		-- // 2.5V 
		fpga_conf_done: in std_logic := 'Z';					-- // 2.5V
		fpga_cvp_confdone: in std_logic;						-- // 2.5V
		fpga_dclk: out std_logic;								-- // 2.5V
		fpga_nconfig: out std_logic;							-- // 2.5V
		fpga_nstatus: inout std_logic;							-- // 2.5V
--		fpga_pr_done: in std_logic;								-- // 2.5V, PR not supported in ES device
--		fpga_pr_error: in std_logic;							-- // 2.5V
--		fpga_pr_ready: in std_logic;							-- // 2.5V
--		fpga_pr_request: out std_logic;							-- // 2.5V

		---------- flash ----------
		fsm_a: inout std_logic_vector(25 downto 1);				-- // 1Gb flash
		fsm_d: inout std_logic_vector(15 downto 0);				-- // 2.5V Flash and FPGA
		flash_cen: out std_logic_vector(1 downto 0);			-- // 2.5V Flash and FPGA
		flash_rdybsyn: in std_logic_vector(1 downto 0);			-- // 2.5V Flash and FPGA
		flash_advn: out std_logic;								-- // 2.5V Flash and FPGA
		flash_clk: out std_logic;								-- // 2.5V Flash and FPGA
		flash_oen: out std_logic;								-- // 2.5V Flash and FPGA
		flash_resetn: out std_logic;-- := '1';					-- // 2.5V Flash and FPGA
		flash_wen: out std_logic;-- := '1';						-- // 2.5V Flash and FPGA

		----------- Configuration -----------
		factory_load: in std_logic;								-- // 2.5V DIPSWITCH - Load Factory or User Design at Power-up
		msel: in std_logic_vector(4 downto 0);-- := "ZZZZZ";	-- // 2.5V DIPSWITCH - Arria V MSEL pins

		pgm_config: in std_logic;--				//2.5V PB to Configure FPGA via FPP
		pgm_sel: in std_logic;--				//2.5V PB to toggle PGM_LEDs
		pgm_led: out std_logic_vector(2 downto 0) := "111";-- 				//2.5V LED configuration will indicate flash page for FPP

		max_conf_done: out std_logic;--				//2.5V LED - ON after PFL Configuration PASS
		max_error: out std_logic;--				//2.5V LED - ON if PFL Configuration FAIL
		max_load: out std_logic;--				//2.5V LED - ON while loading FPP design from flash

		---------- max5-AV bus ---------
		max5_ben: in std_logic_vector(3 downto 0);--				//2.5V Flash and FPGA 
		max5_clk: in std_logic;--				//2.5V Flash and FPGA
		max5_csn: in std_logic;--				//2.5V Flash and FPGA
		max5_oen: in std_logic;--				//2.5V Flash and FPGA
		max5_wen: in std_logic;--				//2.5V Flash and FPGA
		hsma_prsntn: in std_logic;

		---------- On-Board USB-Blaster ----------
		-- AV device doesn't require factory command
--		security_mode: in std_logic;					// 2.5V DIPSWITCH
--		m570_clock: out std_logic;						// 2.5V
--		factory_request: out std_logic;-- := '0';		// 2.5V
--		factory_status: in std_logic;					// 2.5V

		pcie_jtag_en: in std_logic;--					// 2.5V DIPSWITCH
--		m570_pcie_jtag_en: out std_logic;				// 2.5V


		---------- Other PBs & LEDs ----------
		cpu_resetn: out std_logic;						-- // 2.5V Reset PB Max V & Arria V
		max_resetn: in std_logic;						-- // 2.5V Max V Reset PB

--		hsma_prsntn: in std_logic;						-- // 2.5V HSMA Present when '0', LED ON; driven by pull down on HSMC card

		---------- Fan Control ----------
		overtemp: out std_logic;						-- // 2.5V to drive fan
		fan_on_n: in std_logic;							-- // 2.5V DIPSWITCH - a low at this signal will set overtemp to high

		--------- Power Monitor ----------
		sense_cs0n: out std_logic;						-- // 2.5V ADC SPI Bus Chip Select
		sense_sck: out std_logic;						-- // 2.5V ADC SPI Bus Clock
		sense_sdi: out std_logic;						-- // 2.5V ADC SPI Bus Data In
		sense_sdo: in std_logic							-- // 2.5V ADC SPI Bus Data Out
	);

end entity;


architecture rtl of max5 is

	constant MAX_VER: std_logic_vector(7 downto 0) := x"02";

	component reset_generator is
		PORT(
			clk: in std_logic;
			reset_in: in std_logic;
			reset: out std_logic
		);
	end component;

	signal reset_n : std_logic;

	signal pfl_flash_access_request_sig : std_logic;
	signal pfl_nreconfigure_sig : std_logic;
	signal resetn_signal : std_logic;
	signal flash_nce_signal : std_logic;
	signal fpga_nconfig_int : std_logic;
	signal fpga_dclk_sig : std_logic;
	signal pfl_clk_sig : std_logic := '0';


	component slow_clk_gen is
		port (
			clk: in std_logic;
			reset : in std_logic;
			clk_pls_n: out std_logic;
			clk_pls_p: out std_logic;
--			clk_pls_p_deley : out std_logic;
			
			slow_clk : out std_logic -- from 50MHz, it will be 48.828KHz or 20.480us
		);
	end component;

	signal clk_pls_n : std_logic;
	signal clk_pls_p : std_logic;
--	signal clk_pls_p_deley : std_logic;
	signal slow_clk : std_logic;



	component temp_mon is
		port (
			reset_n: in std_logic;
			clk : in std_logic;
			control_gui : in std_logic_vector(7 downto 0);

			clk_pls_n: in std_logic;
			clk_pls_p: in std_logic;
			slow_clk : in std_logic;

			temp_data_r: out std_logic_vector(7 downto 0);
			temp_data_l: out std_logic_vector(7 downto 0);
			fan_cont_out : out std_logic;
			volt_data : out std_logic_vector(15 downto 0)
		);
	end component;

	signal temp_data_r: std_logic_vector(7 downto 0);
	signal temp_data_l: std_logic_vector(7 downto 0);
	signal fan_cont_out : std_logic;
	signal volt_data : std_logic_vector(15 downto 0);

	signal clk_count : integer;
	signal clk_83MHz : std_logic := '0';
	signal clk_62MHz : std_logic := '0';

	component pfl_control is
	port (
		fpga_conf_done : in std_logic;
		fpga_nstatus : inout std_logic;
		reset_n : in std_logic;
		clk_50 : in std_logic;
		clk_config : in std_logic;
		load_image : in std_logic;
		factory_user : in std_logic:='1';
		pgm_sel : in std_logic;
		error_led : out std_logic;	
		fsm_d : inout std_logic_vector(15 downto 0);
		fsm_a : out std_logic_vector(24 downto 0);		--1Gb flash
		flash_cen : out std_logic;
		flash_wen : out std_logic;
		flash_oen : out std_logic;
		flash_clk : out std_logic;
		flash_advn : out std_logic;
		flash_resetn : out std_logic;
		fpga_config_d : out std_logic_vector(15 downto 0);
		fpga_dclk : out std_logic;
		fpga_nconfig : out std_logic;

		srst : in std_logic;
		clk_pls_p: in std_logic; -- from 50MHz, it will be 48.828KHz or 20.480us
		pgm_led : out std_logic_vector(2 downto 0);
		pfl_en_out : out std_logic;
		pfl_pagesel_in : in std_logic_vector(2 downto 0);

--		security_mode 		: in std_logic;--					//2.5V DIPSWITCH
--		m570_clock 			: out std_logic;--				//2.5V
--		factory_request	: out std_logic;-- := '0';--	//2.5V
--		factory_status 	: in std_logic;--					//2.5V

		pcie_jtag_en		: in std_logic--			//2.5V DIPSWITCH
--		m570_pcie_jtag_en	: out std_logic--			//2.5V
	);
	end component;

	signal flash_cen_int : std_logic;

	component power is
		port(
			reset_n: in std_logic;
			clk : in std_logic;
			csense_sdo: in std_logic;
			control_gui : in std_logic_vector(7 downto 0);
			pgm : in std_logic_vector(3 downto 0);

			csense_sck : out std_logic;
			sense_ce0 : out std_logic;
			csense_sdi : out std_logic;
			
			diff_raw : out std_logic_vector(23 downto 0);
			single_raw : out std_logic_vector(23 downto 0);
			
			rail_sel_out : out std_logic_vector(3 downto 0);
			adc_code_mon : out std_logic_vector(23 downto 0);
			sgl_mon : out std_logic;
			power_disable : in std_logic  -- 0: enable  1:disable and output hi-Z
		);
	end component;	
	signal csense_sdo_int : std_logic;
	signal csense_sck_int : std_logic;
	signal csense_csn_int : std_logic;
	signal csense_sdi_int : std_logic;

	component vj_block is
		port (
			reset_n: in std_logic;
			diff_raw : in std_logic_vector(23 downto 0);
			single_raw : in std_logic_vector(23 downto 0);

			temp_data_r : in std_logic_vector(7 downto 0);
			temp_data_l : in std_logic_vector(7 downto 0);
			volt_data : in std_logic_vector(15 downto 0);
			pmon_rails : in std_logic_vector(3 downto 0);

			control_gui : out std_logic_vector(7 downto 0);
			reset_vj: out std_logic;
			MAX_VER : in std_logic_vector(7 downto 0)
		);
	end component;	
	signal diff_raw_int : std_logic_vector(23 downto 0);
	signal single_raw_int : std_logic_vector(23 downto 0);
	signal control_gui_int : std_logic_vector(7 downto 0);


	component q_sys is
		port(
			clk_clk          : in    std_logic := 'X'; -- clk
			reset_reset_n    : in    std_logic := 'X'; -- reset_n
			opencores_i2c_0_export_0_scl_pad_io : inout std_logic;
			opencores_i2c_0_export_0_sda_pad_io : inout std_logic;
			vj_clk_pls_p_export : in std_logic
		);
	end component q_sys;

	component fpga_interface is
		port(
			-- Global signals
			reset_n: in std_logic;
			fsm_clk : in std_logic;

			-- FPGA interface
			max5_csn: in std_logic;
			max5_wen: in std_logic;
			max5_oen: in std_logic;
			max5_ben : in std_logic_vector(3 downto 0);
			max5_clk : in std_logic;
			address: inout std_logic_vector(4 downto 0);
			data: inout std_logic_vector(15 downto 0);

			-- dipswitch/PFL interface
			dsw_pagesel: in std_logic_vector(3 downto 0);
			pfl_pagesel: out std_logic_vector(2 downto 0);
			srst_out : out std_logic;

			-- power data
			diff_raw : in std_logic_vector(23 downto 0);
			single_raw : in std_logic_vector(23 downto 0);
			pfl_en : in std_logic;

			-- clk control
--			clk125_en : out std_logic;
--			clk50_en : out std_logic;
--			clk_sel : in std_logic;
--			clk_enable : in std_logic;

			-- board setting
			sram_mode : out std_logic;
			sram_zz : out std_logic;
			fan_force_on : out std_logic;
			fan_speed : out std_logic_vector(3 downto 0);
			hsma_orsntn : in std_logic;
			MAX_VER : in std_logic_vector(7 downto 0);
			fan_speed_overwrite : out std_logic;
			factory_confign : in std_logic;
			system_clk : in std_logic
		);
	end component;

	signal pfl_pagesel: std_logic_vector(2 downto 0);
	signal srst : std_logic;
	signal fsd_req : std_logic;
	signal pfl_en : std_logic;
	signal fpga_pgm : std_logic_vector(2 downto 0);
	signal fpga_conf_done_int : std_logic;
	signal image_led : std_logic_vector(2 downto 0);

--	signal m570_pcie_jtag_en_int : std_logic;
--	signal m570_clock_int 			: std_logic;--				//2.5V
--	signal factory_request_int	: std_logic;-- := '0';--	//2.5V

	signal cpu_reset_int1, cpu_reset_int2 : std_logic;

	begin


		reset_generator_inst: reset_generator
		PORT MAP(
			clk => clkin_50,
			reset_in => '1',
			reset => reset_n
		);


	slow_clk_gen_inst : slow_clk_gen port map(
			clk => clkin_50,
			reset => reset_n,
			clk_pls_n => clk_pls_n,
			clk_pls_p => clk_pls_p,
--			clk_pls_p_deley => clk_pls_p_deley,
			slow_clk => slow_clk
		);


	temp_mon_inst : temp_mon port map(
			reset_n => reset_n,
			clk => clkin_50,
--			control_gui => control_gui_int,
			control_gui => (others => '0'),
			
			clk_pls_n => clk_pls_n,
			clk_pls_p => clk_pls_p,
			slow_clk => slow_clk,
			
			temp_data_r => temp_data_r,
			temp_data_l => temp_data_l,
			fan_cont_out => fan_cont_out,
			volt_data => volt_data
		);
--	overtemp <= not fan_cont_out; -- turn the FAN on all the time for now
	overtemp <= not fan_on_n; -- turn the FAN on when switch SW1.4 is low





	pfl_control_inst: pfl_control
	PORT MAP(
		fpga_conf_done => fpga_conf_done,
		fpga_nstatus => fpga_nstatus,
--		reset_n => cpu_resetn,
		clk_50 => clkin_50,
		clk_config => clk_config,
		load_image => pgm_config,
		factory_user => (not factory_load),
		pgm_sel => pgm_sel,
		error_led => max_error,
		fsm_d => fsm_d(15 downto 0),
		fsm_a(24 downto 0) => fsm_a(25 downto 1),
		flash_cen => flash_nce_signal,
		flash_wen => flash_wen,
		flash_oen => flash_oen,
		flash_clk => flash_clk,
		flash_advn => flash_advn,
		flash_resetn => flash_resetn,
		fpga_config_d => fpga_config_d(15 downto 0),
		fpga_dclk => fpga_dclk_sig,
		fpga_nconfig => fpga_nconfig_int,
		srst => srst,
		reset_n => reset_n,
		clk_pls_p => clk_pls_p,
		pgm_led => pgm_led,
		pfl_en_out => pfl_en,
		pfl_pagesel_in => pfl_pagesel,

--		m570_clock => m570_clock_int,
--		factory_request => factory_request_int,			
--		m570_pcie_jtag_en => m570_pcie_jtag_en_int,
--		security_mode => security_mode, 		
--		factory_status => factory_status, 	
		pcie_jtag_en => pcie_jtag_en
	);

--	process(security_mode, m570_pcie_jtag_en_int, m570_clock_int, factory_request_int)
--	begin
--		if (security_mode = '0') then
--			m570_pcie_jtag_en <= 'Z';
--			m570_clock <= 'Z';
--			factory_request <= 'Z';
--		else
--			m570_pcie_jtag_en <= not m570_pcie_jtag_en_int;
--			m570_clock <= m570_clock_int;
--			factory_request <= factory_request_int;
--		end if;
--	end process;

--	flash_cen <= flash_nce_signal & flash_nce_signal;	-- access 1 flash at a time, fsm_d x16
--	flash_cen(1) <= flash_nce_signal;
--	flash_cen(1) <= '1';


	max_conf_done <= not fpga_conf_done ;
--	max_error <= fpga_nconfig_int;
	max_load <= fpga_nstatus;

	fpga_nconfig <= fpga_nconfig_int;
	fpga_dclk <= fpga_dclk_sig;




	vj_block_inst: vj_block
	PORT MAP(
			reset_n => reset_n,
			diff_raw => diff_raw_int,
			single_raw => single_raw_int,

--			temp_data_r => temp_data_r,
--			temp_data_l => temp_data_l,
--			volt_data => volt_data,
--			pmon_rails => (others => '0'),


			temp_data_r => (others => '0'),
			temp_data_l => (others => '0'),
			volt_data => (others => '0'),
			pmon_rails => (others => '0'),


			control_gui => control_gui_int,
--			reset_vj: out std_logic;
			MAX_VER => MAX_VER
		);

	power_inst: power
	PORT MAP(
		reset_n => reset_n,
		clk => clkin_50,

		csense_sdo => csense_sdo_int,
		control_gui => control_gui_int,
		pgm => (others => '0'),

		csense_sck => csense_sck_int,
		sense_ce0 => csense_csn_int,
		csense_sdi => csense_sdi_int,

		diff_raw => diff_raw_int,
		single_raw => single_raw_int,

		power_disable => '0'
	);

	csense_sdo_int <= sense_sdo;
	sense_sck <= csense_sck_int;
	sense_cs0n <= '0';
--	sense_cs0n <= csense_csn_int;
	sense_sdi <= csense_sdi_int;



	u0: component q_sys
	PORT MAP(
		clk_clk => clkin_50,								-- clk.clk
		vj_clk_pls_p_export => clk_pls_p,
		reset_reset_n => reset_n,							-- reset.reset_n

		opencores_i2c_0_export_0_scl_pad_io => clock_scl,
		opencores_i2c_0_export_0_sda_pad_io => clock_sda
	);



--  sopc_sys_inst : sopc_sys
--    port map(
--      clk_0 => clkin_50,
--      reset_n => reset_n,
--
--      smb_clk_from_the_i2c_io_sopc_0 => clock_scl,
--      smb_data_to_and_from_the_i2c_io_sopc_0 => clock_sda,
--      clk_pls_n_to_the_i2c_io_sopc_0 => clk_pls_n,
--      clk_pls_p_to_the_i2c_io_sopc_0 => clk_pls_p,
--      slow_clk_to_the_i2c_io_sopc_0 => slow_clk
--    );

	fpga_interface_inst: fpga_interface
	PORT MAP(
		-- Global signals
		reset_n => reset_n,
		fsm_clk => clkin_50,

		-- FPGA interface
		max5_csn => max5_csn,
		max5_wen => max5_wen,
		max5_oen => max5_oen,
--		max5_ben => max5_ben,
		max5_ben => "0000",				-- always enable
		max5_clk => max5_clk,

		address => fsm_a(6 downto 2),	-- to read max_ver in BTS config correctly
--		address => fsm_a(5 downto 1),
		data => fsm_d,

		-- dipswitch/PFL interface
		dsw_pagesel => '0' & fpga_pgm,	-- from PFL block
--		dsw_pagesel => (others => '0'),
		pfl_pagesel => pfl_pagesel,		-- to PFL block
		srst_out => srst,				-- to PFL block

		-- power data
		diff_raw => diff_raw_int,
		single_raw => single_raw_int,
		pfl_en => pfl_en,


		hsma_orsntn => hsma_prsntn,
--		hsma_orsntn => '0',
		MAX_VER => MAX_VER,
		factory_confign => '1',			-- no signal on this project
		system_clk => clkin_50
	);


	process(clkin_50)
	begin
		if(clkin_50'event and clkin_50 = '1')then
			if(fpga_conf_done = '0')then
				cpu_reset_int1 <= '1';
				cpu_reset_int2 <= '1';
				cpu_resetn <= 'Z';
			else
				cpu_reset_int1 <= pfl_en;
				cpu_reset_int2 <= not cpu_reset_int1;
				cpu_resetn <= cpu_reset_int1 or cpu_reset_int2;
			end if;
		end if;
	end process;

end rtl;
