library ieee;
use ieee.std_logic_1164.all;

entity temp_mon is
	port (
		reset_n: in std_logic;
		clk : in std_logic;
		control_gui : in std_logic_vector(7 downto 0);
		
		clk_pls_n: in std_logic;
		clk_pls_p: in std_logic;
		slow_clk : in std_logic;
		

		smb_clk: out std_logic;
		smb_data: inout std_logic;
		temp_data_r: out std_logic_vector(7 downto 0);
		temp_data_l: out std_logic_vector(7 downto 0);
		fan_cont_out : out std_logic;
		volt_data : out std_logic_vector(15 downto 0)
	);
end temp_mon;


architecture RTL of temp_mon is

	component i2c_cont
		port (
			clk: in std_logic;
			reset : in std_logic;
			clk_pls_n: in std_logic;
			clk_pls_p: in std_logic;
			slow_clk : in std_logic;
			smb_clk : out std_logic;
			smb_data : inout std_logic;
			control_gui : in std_logic_vector(7 downto 0);
			data_out_t_r : out std_logic_vector(7 downto 0);
			data_out_t_l : out std_logic_vector(7 downto 0);
			data_out_v : out std_logic_vector(15 downto 0)
		);
	end component;

	component fan_cont is
		port (
			reset_n: in std_logic;
			clk : in std_logic;
			clk_pls_p : in std_logic;
			data_out_t_r : in std_logic_vector(7 downto 0);

			fan_cont_out: out std_logic
		);
	end component;	

--	signal clk_pls_n, clk_pls_p, slow_clk : std_logic;
	signal reset_power : std_logic;
	signal data_out_t_r_int : std_logic_vector(7 downto 0);
--	signal volt_data_mon, volt_data12_mon : std_logic_vector(15 downto 0);
	signal volt_data_mon : std_logic_vector(15 downto 0);

	
begin

	reset_power <= reset_n;

--	u1: gen100k_or_less_pls port map(clk, reset_n, clk_pls_n, clk_pls_p, slow_clk);
	
	u2: i2c_cont port map(clk, reset_power, clk_pls_n, clk_pls_p, slow_clk, 
								smb_clk, smb_data, control_gui,
								data_out_t_r_int, temp_data_l, volt_data_mon);

	temp_data_r <= data_out_t_r_int;
	
	fan_cont_inst : fan_cont port map(
			reset_n => reset_n,
			clk => clk,
			clk_pls_p => clk_pls_p,
			data_out_t_r => data_out_t_r_int,

			fan_cont_out => fan_cont_out
		);
	
	
	volt_data <= volt_data_mon;
	
end rtl;