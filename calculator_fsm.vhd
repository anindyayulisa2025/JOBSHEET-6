library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator_fsm is
    Port (
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR(15 downto 0);
        btnU : in  STD_LOGIC; -- Load Operand A
        btnD : in  STD_LOGIC; -- Load Operand B
        btnC : in  STD_LOGIC; -- Hitung & Enter / Reset Loop
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        an   : out STD_LOGIC_VECTOR(3 downto 0);
        dp   : out STD_LOGIC
    );
end calculator_fsm;

architecture Behavioral of calculator_fsm is

    component debounce is
        Generic (CLK_FREQ_HZ: integer := 100_000_000; STABLE_MS: integer := 10);
        Port (clk : in STD_LOGIC; btn_in : in STD_LOGIC; btn_out : out STD_LOGIC);
    end component;

    component edge_detect is
        Port (clk : in STD_LOGIC; sig_in : in STD_LOGIC; pulse : out STD_LOGIC);
    end component;

    component seven_seg_driver is
        Port (
            clk      : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR(15 downto 0);
            seg      : out STD_LOGIC_VECTOR(6 downto 0);
            an       : out STD_LOGIC_VECTOR(3 downto 0);
            dp       : out STD_LOGIC
        );
    end component;

    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    signal btnU_db, btnD_db, btnC_db          : STD_LOGIC;
    signal btnU_pulse, btnD_pulse, btnC_pulse : STD_LOGIC;

    signal reg_a, reg_b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal alu_out      : STD_LOGIC_VECTOR(15 downto 0);
    signal display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

    db_U : debounce port map(clk => clk, btn_in => btnU, btn_out => btnU_db);
    ed_U : edge_detect port map(clk => clk, sig_in => btnU_db, pulse => btnU_pulse);

    db_D : debounce port map(clk => clk, btn_in => btnD, btn_out => btnD_db);
    ed_D : edge_detect port map(clk => clk, sig_in => btnD_db, pulse => btnD_pulse);

    db_C : debounce port map(clk => clk, btn_in => btnC, btn_out => btnC_db);
    ed_C : edge_detect port map(clk => clk, sig_in => btnC_db, pulse => btnC_pulse);

    alu_inst : entity work.alu8
        port map (
            a      => reg_a,
            b      => reg_b,
            op_sel => sw(13 downto 12),
            result => alu_out
        );

    display_inst : seven_seg_driver
        port map (
            clk => clk, data_in => display_data, seg => seg, an => an, dp => dp
        );

    -- Process 1 (Sinkron)
    process(clk)
    begin
        if rising_edge(clk) then
            state <= next_state;

            if state = S_WAIT_A and btnU_pulse = '1' then
                reg_a <= sw(7 downto 0);
            elsif state = S_WAIT_B and btnD_pulse = '1' then
                reg_b <= sw(7 downto 0);
            end if;
        end if;
    end process;

    -- Process 2 (Kombinasional)
    process(state, btnU_pulse, btnD_pulse, btnC_pulse)
    begin
        next_state <= state;

        case state is
            when S_WAIT_A =>
                if btnU_pulse = '1' then
                    next_state <= S_WAIT_B;
                end if;

            when S_WAIT_B =>
                if btnD_pulse = '1' then
                    next_state <= S_COMPUTE;
                end if;

            when S_COMPUTE =>
                next_state <= S_SHOW;

            when S_SHOW =>
                if btnC_pulse = '1' then
                    next_state <= S_WAIT_A;
                end if;
        end case;
    end process;

    -- Output Decoder
    process(state, reg_a, reg_b, alu_out)
    begin
        case state is
            when S_WAIT_A =>
                display_data <= X"00" & reg_a;
            when S_WAIT_B =>
                display_data <= X"00" & reg_b;
            when S_COMPUTE | S_SHOW =>
                display_data <= alu_out;
        end case;
    end process;

end Behavioral;