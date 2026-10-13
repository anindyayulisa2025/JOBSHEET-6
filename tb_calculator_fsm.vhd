library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture Behavior of tb_calculator_fsm is
    signal clk  : STD_LOGIC := '0';
    signal sw   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal btnU : STD_LOGIC := '0';
    signal btnD : STD_LOGIC := '0';
    signal btnC : STD_LOGIC := '0';
    signal seg  : STD_LOGIC_VECTOR(6 downto 0);
    signal an   : STD_LOGIC_VECTOR(3 downto 0);
    signal dp   : STD_LOGIC;

    constant clk_period : time := 10 ns;
begin
    uut: entity work.calculator_fsm
        port map (
            clk => clk, sw => sw, btnU => btnU, btnD => btnD, btnC => btnC,
            seg => seg, an => an, dp => dp
        );

    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;

        -- 1. Input Operand A = 12 (0x0C) -> Tekan btnU
        sw(7 downto 0) <= X"0C";
        wait for 20 ms; btnU <= '1'; wait for 20 ms; btnU <= '0';
        wait for 50 ms;

        -- 2. Input Operand B = 4 (0x04) -> Tekan btnD
        sw(7 downto 0) <= X"04";
        wait for 20 ms; btnD <= '1'; wait for 20 ms; btnD <= '0';
        wait for 50 ms;

        -- 3. Uji Operasi Perkalian (*) -> sw(13 downto 12) = "10"
        sw(13 downto 12) <= "10";
        wait for 50 ms;

        -- 4. Uji Operasi Pembagian (/) -> sw(13 downto 12) = "11"
        sw(13 downto 12) <= "11";
        wait for 50 ms;

        -- 5. Reset FSM kembali ke S_WAIT_A -> Tekan btnC
        btnC <= '1'; wait for 20 ms; btnC <= '0';
        
        wait;
    end process;
end Behavior;