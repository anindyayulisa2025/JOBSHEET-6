library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Port (
        clk     : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR(15 downto 0);
        seg     : out STD_LOGIC_VECTOR(6 downto 0);
        an      : out STD_LOGIC_VECTOR(3 downto 0);
        dp      : out STD_LOGIC
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal clk_divider    : unsigned(16 downto 0) := (others => '0');
    signal digit_sel      : unsigned(1 downto 0) := "00";
    signal current_nibble : STD_LOGIC_VECTOR(3 downto 0);

    function hex_to_seg(digit : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when X"0" => return "1000000";
            when X"1" => return "1111001";
            when X"2" => return "0100100";
            when X"3" => return "0110000";
            when X"4" => return "0011001";
            when X"5" => return "0010010";
            when X"6" => return "0000010";
            when X"7" => return "1111000";
            when X"8" => return "0000000";
            when X"9" => return "0010000";
            when X"A" => return "0001000";
            when X"B" => return "0000011";
            when X"C" => return "1000111";
            when X"D" => return "0100001";
            when X"E" => return "0000110";
            when X"F" => return "0001110";
            when others => return "1111111";
        end case;
    end function;

begin
    dp <= '1'; -- Non-aktifkan decimal point

    process(clk)
    begin
        if rising_edge(clk) then
            clk_divider <= clk_divider + 1;
        end if;
    end process;

    digit_sel <= clk_divider(16 downto 15);

    process(digit_sel, data_in)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110"; current_nibble <= data_in(3 downto 0);
            when "01" =>
                an <= "1101"; current_nibble <= data_in(7 downto 4);
            when "10" =>
                an <= "1011"; current_nibble <= data_in(11 downto 8);
            when "11" =>
                an <= "0111"; current_nibble <= data_in(15 downto 12);
            when others =>
                an <= "1111"; current_nibble <= "0000";
        end case;
    end process;

    seg <= hex_to_seg(current_nibble);
end Behavioral;