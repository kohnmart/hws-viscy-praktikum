library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- REGFILE_TB entity declaration
entity REGFILE_TB is
end REGFILE_TB;

architecture TESTBENCH of REGFILE_TB is
    -- Declare REGFILE component
    component REGFILE is
        port (
            clk: in std_logic;                             -- clock signal
            in_data: in std_logic_vector (15 downto 0);    -- 16-bit input bus
            in_sel: in std_logic_vector (2 downto 0);      -- 3-bit register selector
            out0_data: out std_logic_vector (15 downto 0); -- 16-bit output 0
            out0_sel: in std_logic_vector (2 downto 0);    -- 3-bit output 0 selector
            out1_data: out std_logic_vector (15 downto 0); -- 16-bit output 1
            out1_sel: in std_logic_vector (2 downto 0);    -- 3-bit output 1 selector
            load_lo, load_hi: in std_logic                 -- load low or high byte
        );
    end component;
    
    -- Point REGFILE component to the submodule's RTL architecture
    for TEST_REGFILE: REGFILE use entity WORK.REGFILE(RTL);

    -- 2D-array (8x 16-bit registers)
    type t_regfile is array (0 to 7) of std_logic_vector(15 downto 0);

    -- Internal signals
    signal in_data, out0_data, out1_data: std_logic_vector (15 downto 0);
    signal in_sel, out0_sel, out1_sel: std_logic_vector (2 downto 0);
    signal clk, load_lo, load_hi: std_logic;
    -- Internal register (to keep track of expected output values)
    signal reg: t_regfile;
begin
    -- Instantiate REGFILE
    TEST_REGFILE: REGFILE port map(
        clk => clk,
        in_data => in_data,
        in_sel => in_sel,
        out0_data => out0_data,
        out0_sel => out0_sel,
        out1_data => out1_data,
        out1_sel => out1_sel,
        load_lo => load_lo,
        load_hi => load_hi
    );

    process
        -- Run clock cycle
        procedure run_cycle is
            variable period: time := 10 ns;
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end procedure;

        -- Random 16-bit vector
        function rand_slv (seed: INTEGER) return std_logic_vector is
            variable r: INTEGER;
            variable bit_s: INTEGER;
            variable a: INTEGER := 214013;
            variable c: INTEGER := 2531001;
            variable max: INTEGER := 2 ** 8;
            variable slv: std_logic_vector(15 downto 0);
        begin
            -- Generate a random value for each of the vector's bits
            for i in slv'range loop
                -- New seed for every bit (clamped)
                bit_s := (seed * (i + 1)) mod max;
                -- Pseudo random value using a linear congruential generator
                -- Reference: https://rosettacode.org/wiki/Linear_congruential_generator
                r := (a * bit_s + c) mod max;
                -- Assign 1 to bit if random value is > max/2 (50:50 chance)
                if r > (max / 2) then
                    slv(i) := '1';
                else
                    slv(i) := '0';
                end if;
            end loop;
            return slv;
        end function;
        
        -- Run full register file test
        procedure test_regfile (lo, hi, rand: in std_logic; data: in std_logic_vector(15 downto 0); seed: in INTEGER) is
            variable test_data: std_logic_vector(15 downto 0);
        begin
            test_data := data;
            load_lo <= lo;
            load_hi <= hi;
            -- Set low and high bytes using data (if selected)
            for i in 0 to 7 loop
                -- Decide if random data should be used
                if rand = '1' then
                    test_data := rand_slv(i + seed);
                end if;
                -- Set test register inputs
                in_sel <= std_logic_vector(to_unsigned(i, 3));
                in_data <= test_data;
                -- Set low byte of internal register
                if lo = '1' then
                    reg(i)(7 downto 0) <= test_data(7 downto 0);
                end if;
                -- Set high byte of internal register
                if hi = '1' then
                    reg(i)(15 downto 8) <= test_data(15 downto 8);
                end if;
                -- Run clock cycle
                run_cycle;
            end loop;
            -- Test outputs
            for i in 0 to 7 loop
                -- Test out0
                out0_sel <= std_logic_vector(to_unsigned(i, 3));
                run_cycle;
                -- Test low byte (compare to internal register)
                assert out0_data(7 downto 0) = reg(i)(7 downto 0)
                    report "Received unexpected low byte for register "
                        & INTEGER'image(i)
                        & " on out0";
                -- Test high byte (compare to internal register)
                assert out0_data(15 downto 8) = reg(i)(15 downto 8)
                    report "Received unexpected high byte for register "
                        & INTEGER'image(i)
                        & " on out0";
                -- Test every out1 for current out0
                for j in 0 to 7 loop
                    out1_sel <= std_logic_vector(to_unsigned(j, 3));
                    run_cycle;
                    -- Test low byte (compare to internal register)
                    assert out1_data(7 downto 0) = reg(j)(7 downto 0)
                        report "Received unexpected low byte for register "
                            & INTEGER'image(j)
                            & " on out1";
                    -- Test high byte (compare to internal register)
                    assert out1_data(15 downto 8) = reg(j)(15 downto 8)
                        report "Received unexpected high byte for register "
                            & INTEGER'image(j)
                            & " on out1";
                end loop;
            end loop;
        end procedure;
    begin
        -- Initialize all registers with 0
        test_regfile('1', '1', '0', "0000000000000000", 0);

        for i in 1 to 10000 loop
            -- Test setting low byte with random data
            test_regfile('1', '0', '1', "XXXXXXXXXXXXXXXX", i);
            -- Test setting high byte with random data
            test_regfile('0', '1', '1', "XXXXXXXXXXXXXXXX", i);
            -- Test setting low and high byte with random data
            test_regfile('1', '1', '1', "XXXXXXXXXXXXXXXX", i);
        end loop;

    -- Print a note & finish simulation now
    assert false report "Simulation finished" severity note;
    wait;               -- end simulation
end process;
end architecture;
