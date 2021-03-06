library ieee;
use ieee.std_logic_1164.all;

entity vj_avalon_master is
	port (
		reset_n: in std_logic;
		clk : in std_logic;
		clk_pls_p: in std_logic;

		address : out std_logic_vector(31 downto 0);
		write_n : out std_logic;
		read_n : out std_logic;
		waitrequest_n : in std_logic;
		
		data_in : in  std_logic_vector(31 downto 0);
		data_out : out std_logic_vector(31 downto 0)
	);
end vj_avalon_master;


architecture rtl of vj_avalon_master is

	component vj_avalon_encode
		port (
			system_clk : in std_logic;
			
			tck : IN STD_LOGIC;
			cdr_in : IN STD_LOGIC;
			ir_in : IN std_logic_vector(1 downto 0);
			data_in: in std_logic_vector(31 downto 0);
			read_triger_n : in std_logic;
			waitrequest_n : in std_logic;

			data_out : OUT STD_LOGIC
		  );
	end component;
	
	
	component vj_inf2
		PORT(
			ir_out		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			tdo		: IN STD_LOGIC ;
			ir_in		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			tck		: OUT STD_LOGIC ;
			tdi		: OUT STD_LOGIC ;
			virtual_state_cdr		: OUT STD_LOGIC ;
			virtual_state_cir		: OUT STD_LOGIC ;
			virtual_state_e1dr		: OUT STD_LOGIC ;
			virtual_state_e2dr		: OUT STD_LOGIC ;
			virtual_state_pdr		: OUT STD_LOGIC ;
			virtual_state_sdr		: OUT STD_LOGIC ;
			virtual_state_udr		: OUT STD_LOGIC ;
			virtual_state_uir		: OUT STD_LOGIC 
		);
	END component;
	
	
	component vj_avalon_decode
		port (
			system_clk : in std_logic;
			clk_pls_p : in std_logic;
			
			tck : in std_logic;
			data_in : IN STD_LOGIC;
			ir_in : IN std_logic_vector(1 downto 0);
			sdr_in : IN STD_LOGIC;
			e1dr_in : in std_logic;
			reset_in : in std_logic;
			waitrequest_n : in std_logic;
			
			data_out : out std_logic_vector(31 downto 0);
			address_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			write_triger_n : out std_logic;
			read_triger_n : out std_logic
		  );
	end component;	

	signal tck, cdr, tdo, tdi, sdr, e1dr : std_logic;
	signal ir_in : std_logic_vector(1 downto 0);
	signal vj_add : std_logic_vector(3 downto 0);
	signal reg : std_logic_vector(15 downto 0);
	signal pmon_rails_int : std_logic_vector(2 downto 0);
	
	signal control_gui : std_logic_vector(7 downto 0);
	
	
	signal read_n_int, write_n_int : std_logic;
	signal data_out_int : std_logic_vector(31 downto 0);
begin

	vj_avalon_encode_inst: vj_avalon_encode port map(clk, tck, cdr, ir_in, data_in, read_n_int, waitrequest_n, tdo);
	
	vj_avalon_decode_inst: vj_avalon_decode port map(clk, clk_pls_p, tck, tdi, ir_in, sdr, e1dr, reset_n, waitrequest_n, data_out_int, address, write_n_int, read_n_int);

	vj_inf2_inst : vj_inf2 PORT MAP (
			ir_out	 => ir_in,
			tdo	 => tdo,
			ir_in	 => ir_in,
			tck	 => tck,
			tdi	 => tdi,
			virtual_state_cdr	 => cdr,
			virtual_state_e1dr	 => e1dr,
			virtual_state_sdr	 => sdr
		);
		
	
	process(reset_n, clk)begin
		if(reset_n = '0')then
			data_out <= (others => '0');
			read_n <= '1';
			write_n <= '1';
		elsif(clk'event and clk = '1')then
			data_out <= data_out_int;
			read_n <= read_n_int;
			write_n <= write_n_int;
		end if;
	end process;

end rtl;




-- megafunction wizard: %Virtual JTAG%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: sld_virtual_jtag 

-- ============================================================
-- File Name: vj_inf2.vhd
-- Megafunction Name(s):
-- 			sld_virtual_jtag
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 10.0 Build 218 06/27/2010 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2010 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY vj_inf2 IS
	PORT
	(
		ir_out		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		tdo		: IN STD_LOGIC ;
		ir_in		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		tck		: OUT STD_LOGIC ;
		tdi		: OUT STD_LOGIC ;
		virtual_state_cdr		: OUT STD_LOGIC ;
		virtual_state_cir		: OUT STD_LOGIC ;
		virtual_state_e1dr		: OUT STD_LOGIC ;
		virtual_state_e2dr		: OUT STD_LOGIC ;
		virtual_state_pdr		: OUT STD_LOGIC ;
		virtual_state_sdr		: OUT STD_LOGIC ;
		virtual_state_udr		: OUT STD_LOGIC ;
		virtual_state_uir		: OUT STD_LOGIC 
	);
END vj_inf2;


ARCHITECTURE SYN OF vj_inf2 IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC ;
	SIGNAL sub_wire6	: STD_LOGIC ;
	SIGNAL sub_wire7	: STD_LOGIC ;
	SIGNAL sub_wire8	: STD_LOGIC ;
	SIGNAL sub_wire9	: STD_LOGIC ;
	SIGNAL sub_wire10	: STD_LOGIC ;



	COMPONENT sld_virtual_jtag
	GENERIC (
		sld_auto_instance_index		: STRING;
		sld_instance_index		: NATURAL;
		sld_ir_width		: NATURAL;
		sld_sim_action		: STRING;
		sld_sim_n_scan		: NATURAL;
		sld_sim_total_length		: NATURAL;
		lpm_type		: STRING
	);
	PORT (
			virtual_state_cir	: OUT STD_LOGIC ;
			virtual_state_pdr	: OUT STD_LOGIC ;
			ir_in	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			tdi	: OUT STD_LOGIC ;
			virtual_state_udr	: OUT STD_LOGIC ;
			ir_out	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			tck	: OUT STD_LOGIC ;
			virtual_state_e1dr	: OUT STD_LOGIC ;
			virtual_state_uir	: OUT STD_LOGIC ;
			tdo	: IN STD_LOGIC ;
			virtual_state_cdr	: OUT STD_LOGIC ;
			virtual_state_e2dr	: OUT STD_LOGIC ;
			virtual_state_sdr	: OUT STD_LOGIC 
	);
	END COMPONENT;

BEGIN
	virtual_state_cir    <= sub_wire0;
	virtual_state_pdr    <= sub_wire1;
	ir_in    <= sub_wire2(1 DOWNTO 0);
	tdi    <= sub_wire3;
	virtual_state_udr    <= sub_wire4;
	tck    <= sub_wire5;
	virtual_state_e1dr    <= sub_wire6;
	virtual_state_uir    <= sub_wire7;
	virtual_state_cdr    <= sub_wire8;
	virtual_state_e2dr    <= sub_wire9;
	virtual_state_sdr    <= sub_wire10;

	sld_virtual_jtag_component : sld_virtual_jtag
	GENERIC MAP (
		sld_auto_instance_index => "NO",
		sld_instance_index => 1,
		sld_ir_width => 2,
		sld_sim_action => "",
		sld_sim_n_scan => 0,
		sld_sim_total_length => 0,
		lpm_type => "sld_virtual_jtag"
	)
	PORT MAP (
		ir_out => ir_out,
		tdo => tdo,
		virtual_state_cir => sub_wire0,
		virtual_state_pdr => sub_wire1,
		ir_in => sub_wire2,
		tdi => sub_wire3,
		virtual_state_udr => sub_wire4,
		tck => sub_wire5,
		virtual_state_e1dr => sub_wire6,
		virtual_state_uir => sub_wire7,
		virtual_state_cdr => sub_wire8,
		virtual_state_e2dr => sub_wire9,
		virtual_state_sdr => sub_wire10
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "MAX II"
-- Retrieval info: PRIVATE: show_jtag_state STRING "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: SLD_AUTO_INSTANCE_INDEX STRING "NO"
-- Retrieval info: CONSTANT: SLD_INSTANCE_INDEX NUMERIC "1"
-- Retrieval info: CONSTANT: SLD_IR_WIDTH NUMERIC "2"
-- Retrieval info: CONSTANT: SLD_SIM_ACTION STRING ""
-- Retrieval info: CONSTANT: SLD_SIM_N_SCAN NUMERIC "0"
-- Retrieval info: CONSTANT: SLD_SIM_TOTAL_LENGTH NUMERIC "0"
-- Retrieval info: USED_PORT: ir_in 0 0 2 0 OUTPUT NODEFVAL "ir_in[1..0]"
-- Retrieval info: USED_PORT: ir_out 0 0 2 0 INPUT NODEFVAL "ir_out[1..0]"
-- Retrieval info: USED_PORT: tck 0 0 0 0 OUTPUT NODEFVAL "tck"
-- Retrieval info: USED_PORT: tdi 0 0 0 0 OUTPUT NODEFVAL "tdi"
-- Retrieval info: USED_PORT: tdo 0 0 0 0 INPUT NODEFVAL "tdo"
-- Retrieval info: USED_PORT: virtual_state_cdr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_cdr"
-- Retrieval info: USED_PORT: virtual_state_cir 0 0 0 0 OUTPUT NODEFVAL "virtual_state_cir"
-- Retrieval info: USED_PORT: virtual_state_e1dr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_e1dr"
-- Retrieval info: USED_PORT: virtual_state_e2dr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_e2dr"
-- Retrieval info: USED_PORT: virtual_state_pdr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_pdr"
-- Retrieval info: USED_PORT: virtual_state_sdr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_sdr"
-- Retrieval info: USED_PORT: virtual_state_udr 0 0 0 0 OUTPUT NODEFVAL "virtual_state_udr"
-- Retrieval info: USED_PORT: virtual_state_uir 0 0 0 0 OUTPUT NODEFVAL "virtual_state_uir"
-- Retrieval info: CONNECT: @ir_out 0 0 2 0 ir_out 0 0 2 0
-- Retrieval info: CONNECT: @tdo 0 0 0 0 tdo 0 0 0 0
-- Retrieval info: CONNECT: ir_in 0 0 2 0 @ir_in 0 0 2 0
-- Retrieval info: CONNECT: tck 0 0 0 0 @tck 0 0 0 0
-- Retrieval info: CONNECT: tdi 0 0 0 0 @tdi 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_cdr 0 0 0 0 @virtual_state_cdr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_cir 0 0 0 0 @virtual_state_cir 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_e1dr 0 0 0 0 @virtual_state_e1dr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_e2dr 0 0 0 0 @virtual_state_e2dr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_pdr 0 0 0 0 @virtual_state_pdr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_sdr 0 0 0 0 @virtual_state_sdr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_udr 0 0 0 0 @virtual_state_udr 0 0 0 0
-- Retrieval info: CONNECT: virtual_state_uir 0 0 0 0 @virtual_state_uir 0 0 0 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL vj_inf.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL vj_inf.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL vj_inf.cmp FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL vj_inf.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL vj_inf_inst.vhd FALSE
-- Retrieval info: LIB_FILE: altera_mf
