library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity data_enc is 
        port (
              -- inputs:
                clk : IN STD_LOGIC;
                cdr_in : IN STD_LOGIC;
                ir_in : IN std_logic_vector(1 downto 0);
                vj_add : IN std_logic_vector(3 downto 0);
--				ave_v, ave_a, ave_w, max_v, max_a, max_w, min_v, min_a, min_w : in std_logic_vector(15 downto 0);
				diff_raw : in std_logic_vector(23 downto 0);
				single_raw : in std_logic_vector(23 downto 0);
--				temp_data_r : in std_logic_vector(15 downto 0);
--				temp_data_l : in std_logic_vector(15 downto 0);
				temp_data_r : in std_logic_vector(7 downto 0);
				temp_data_l : in std_logic_vector(7 downto 0);
				volt_data : in std_logic_vector(15 downto 0);
				reg : in std_logic_vector(15 downto 0);

              -- outputs:
                 signal disp_out : OUT STD_LOGIC
              );
end entity data_enc;


architecture europa of data_enc is
	signal count : integer range 0 to 24;
	signal dip_out_int : std_logic;
	signal disp_in : std_logic_vector(23 downto 0);
begin

	process(clk)begin
		if(clk'event and clk = '1')then
			if(cdr_in = '1' and ir_in = "01")then
				count <= 0;
			else
				if(vj_add(3) = '1')then
					if(count = 16)then
						count <= 16;
					else
						count <= count + 1;
					end if;
				else
					if(count = 24)then
						count <= 24;
					else
						count <= count + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(count, disp_in, vj_add)begin
		if(vj_add(3) = '1')then
			case count is
				when 0 => disp_out <= disp_in(0);
				when 1 => disp_out <= disp_in(1);
				when 2 => disp_out <= disp_in(2);
				when 3 => disp_out <= disp_in(3);
				when 4 => disp_out <= disp_in(4);
				when 5 => disp_out <= disp_in(5);
				when 6 => disp_out <= disp_in(6);
				when 7 => disp_out <= disp_in(7);
				when 8 => disp_out <= disp_in(8);
				when 9 => disp_out <= disp_in(9);
				when 10 => disp_out <= disp_in(10);
				when 11 => disp_out <= disp_in(11);
				when 12 => disp_out <= disp_in(12);
				when 13 => disp_out <= disp_in(13);
				when 14 => disp_out <= disp_in(14);
				when 15 => disp_out <= disp_in(15);
				when others => disp_out <= '0';
			end case;
		else
			case count is
				when 0 => disp_out <= disp_in(0);
				when 1 => disp_out <= disp_in(1);
				when 2 => disp_out <= disp_in(2);
				when 3 => disp_out <= disp_in(3);
				when 4 => disp_out <= disp_in(4);
				when 5 => disp_out <= disp_in(5);
				when 6 => disp_out <= disp_in(6);
				when 7 => disp_out <= disp_in(7);
				when 8 => disp_out <= disp_in(8);
				when 9 => disp_out <= disp_in(9);
				when 10 => disp_out <= disp_in(10);
				when 11 => disp_out <= disp_in(11);
				when 12 => disp_out <= disp_in(12);
				when 13 => disp_out <= disp_in(13);
				when 14 => disp_out <= disp_in(14);
				when 15 => disp_out <= disp_in(15);
				when 16 => disp_out <= disp_in(16);
				when 17 => disp_out <= disp_in(17);
				when 18 => disp_out <= disp_in(18);
				when 19 => disp_out <= disp_in(19);
				when 20 => disp_out <= disp_in(20);
				when 21 => disp_out <= disp_in(21);
				when 22 => disp_out <= disp_in(22);
				when 23 => disp_out <= disp_in(23);
				when others => disp_out <= '0';
			end case;
		end if;
	end process;

	process(clk)begin
		if(clk'event and clk = '1')then
			case vj_add is
				when "0000" => disp_in <= diff_raw;
				when "0001" => disp_in <= single_raw;
			
				when "1010" => disp_in(15 downto 0) <= volt_data;
				when "1011" => disp_in(15 downto 0) <= "00000000" & temp_data_r;
				when "1100" => disp_in(15 downto 0) <= "00000000" & temp_data_l;
				when "1101" => disp_in(15 downto 0) <= reg;
				when "1111" => disp_in(15 downto 0) <= x"AC81"; -- unique ID 
				when others => null;
			end case;
		end if;
	end process;

end europa;

