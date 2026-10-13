library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
    Port (
        a      : in  STD_LOGIC_VECTOR(7 downto 0);
        b      : in  STD_LOGIC_VECTOR(7 downto 0);
        op_sel : in  STD_LOGIC_VECTOR(1 downto 0); -- sw(13 downto 12)
        result : out STD_LOGIC_VECTOR(15 downto 0)
    );
end alu8;

architecture Behavioral of alu8 is
begin
    process(a, b, op_sel)
        variable temp_a, temp_b : unsigned(15 downto 0);
    begin
        temp_a := resize(unsigned(a), 16);
        temp_b := resize(unsigned(b), 16);
        
        case op_sel is
            when "00" => -- Penjumlahan (+)
                result <= std_logic_vector(temp_a + temp_b);
                
            when "01" => -- Pengurangan (-)
                result <= std_logic_vector(temp_a - temp_b);
                
            when "10" => -- Perkalian (*)
                result <= std_logic_vector(unsigned(a) * unsigned(b));
                
            when "11" => -- Pembagian (/)
                if unsigned(b) = 0 then
                    result <= X"EEEE"; -- Error penanganan bagi 0
                else
                    result <= std_logic_vector(resize(unsigned(a) / unsigned(b), 16));
                end if;
                
            when others =>
                result <= (others => '0');
        end case;
    end process;
end Behavioral;