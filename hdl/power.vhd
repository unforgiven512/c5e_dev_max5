library ieee;
use ieee.std_logic_1164.all;

entity power is
	port (
		reset_n: in std_logic;
		clk : in std_logic;
		csense_sdo: in std_logic;
		control_gui : in std_logic_vector(7 downto 0);
		pgm : in std_logic_vector(3 downto 0);

		csense_sck : out std_logic;
		sense_ce0 : out std_logic;
--		sense_ce1 : out std_logic;
		csense_sdi : out std_logic;
		
		diff_raw : out std_logic_vector(23 downto 0);
		single_raw : out std_logic_vector(23 downto 0);
		
		rail_sel_out : out std_logic_vector(3 downto 0);
		adc_code_mon : out std_logic_vector(23 downto 0);
		sgl_mon : out std_logic;
		power_disable : in std_logic  -- 0: enable  1:disable and output hi-Z

	);
end power;


architecture rtl of power is

	component ltc2418_cont
		port
		(
			reset_n: in std_logic;
			clk : in std_logic;
			sdo_in : in std_logic;
			rail_sel : in std_logic_vector(3 downto 0);
			
			clk_1M_out : out std_logic;
			cs_out0 : out std_logic;
--			cs_out1 : out std_logic;
			sdi : out std_logic;
			dclk : out std_logic;
			dec_data_out : out std_logic_vector(23 downto 0);
			sgl_out : out std_logic
		);
	end component;
	
	signal rail_sel : std_logic_vector(3 downto 0);
	signal dclk : std_logic;
	signal adc_code : std_logic_vector(23 downto 0);
	signal sgl : std_logic;


	signal csense_sck_int : std_logic;
	signal sense_ce0_int : std_logic;
--	signal sense_ce1_int : std_logic;
	signal csense_sdi_int : std_logic;

	
	
	component issp is
		port (
			probe: in std_logic_vector(25 downto 0);
			source: out std_logic
		);
	end component;	
	signal probe : std_logic_vector(23 downto 0);
	signal source : std_logic;
		
	signal diff_raw_mon : std_logic_vector(23 downto 0);
	signal single_raw_mon : std_logic_vector(23 downto 0);
		
begin

	process(control_gui(7), pgm)begin
		if(control_gui(7) = '1')then
			rail_sel <= control_gui(3 downto 0);
		else
			rail_sel <= pgm;
		end if;
	end process;

--	u1:	ltc2418_cont port map(reset_n, clk, csense_sdo, rail_sel, csense_sck_int, sense_ce0_int, sense_ce1_int,
--								csense_sdi_int, dclk, adc_code, sgl);
	u1:	ltc2418_cont port map(reset_n, clk, csense_sdo, rail_sel, csense_sck_int, sense_ce0_int,
								csense_sdi_int, dclk, adc_code, sgl);


	rail_sel_out <= rail_sel;
	adc_code_mon <= adc_code;
	sgl_mon <= sgl;


--	process(power_disable, csense_sck_int, sense_ce0_int, sense_ce1_int, csense_sdi_int)begin
	process(power_disable, csense_sck_int, sense_ce0_int, csense_sdi_int)begin
		if(power_disable = '1')then
			csense_sck <= 'Z';
			sense_ce0 <= 'Z';
--			sense_ce1 <= 'Z';
			csense_sdi <= 'Z';
		else
			csense_sck <= csense_sck_int;
			sense_ce0 <= sense_ce0_int;
--			sense_ce1 <= sense_ce1_int;
			csense_sdi <= csense_sdi_int;
		end if;
	end process;


	process(reset_n, clk)begin
		if(reset_n = '0')then
			diff_raw_mon <= (others => '0');
			single_raw_mon <= (others => '0');
		elsif(clk'event and clk = '1')then
			if(dclk = '0')then
				if(sgl='0')then
					diff_raw_mon <= adc_code;
				else
					single_raw_mon <= adc_code;
				end if;
			end if;
		end if;
	end process;


	diff_raw <= diff_raw_mon;
	single_raw <= single_raw_mon;
	
end rtl;