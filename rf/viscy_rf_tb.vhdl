library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity VISCY_RF_TB is
end VISCY_RF_TB;


architecture TESTBENCH of VISCY_RF_TB is

  -- Component declaration ...
  component VISCY_REGFILE
    port ( clk: in std_logic;
    out0_data: out std_logic_vector (15 downto 0); -- Datenausgang 0
    out0_sel: in std_logic_vector (2 downto 0); -- Register-Nr. 0
    out1_data: out std_logic_vector (15 downto 0); -- Datenausgang 1
    out1_sel: in std_logic_vector (2 downto 0); -- Register-Nr. 1
    in_data: in std_logic_vector (15 downto 0); -- Dateneingang
    in_sel: in std_logic_vector (2 downto 0); -- Register-Wahl
    load_lo, load_hi: in std_logic -- Register laden
    );
  end component;

  -- Clock period ...
  constant period: time := 10 ns;

  -- Signals ...
  signal clk, load_lo, load_hi: std_logic;
  signal out0_data, out1_data, in_data : std_logic_vector (15 downto 0);
  signal out0_sel, out1_sel, in_sel : std_logic_vector (2 downto 0);

  type t_testdata is array (0 to 7) of std_logic_vector(15 downto 0);
  signal testdata: t_testdata;

begin

  -- Instantiate regfile ...
  U_REGFILE : VISCY_REGFILE port map (
    clk => clk, 
    out0_data => out0_data, 
    out0_sel => out0_sel, 
    out1_data => out1_data, 
    out1_sel => out1_sel, 
    in_data => in_data, 
    in_sel => in_sel,
    load_lo => load_lo,
    load_hi => load_hi
  );

  -- Process for applying patterns
  process

    -- Helper to perform one clock cycle...
    procedure run_cycle is
    begin
      clk <= '0';
      wait for period / 2;
      clk <= '1';
      wait for period / 2;
    end procedure;

  begin

    -- Reset: Alle Register auf 0 setzen...
    run_cycle;
    in_data <= "0000000000000000";
    load_hi <= '1'; load_lo <= '1';
    for i in 0 to 7 loop
      in_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
    end loop;

    -- Registerinhalte lesen & überprüfen...
    for i in 0 to 7 loop
      out0_sel <= std_logic_vector (to_unsigned (i, 3));
      out1_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
      assert out0_data = "0000000000000000" report "Reset aller bytes funktioniert nicht";
      assert out1_data = "0000000000000000" report "Reset aller bytes funktioniert nicht";
    end loop;

    -- Reset auf 0 funktioniert in allen Registern

    -- nur High-Bytes schreiben...
    in_data <= "1111111110010100";
    load_hi <= '1'; load_lo <= '0';
    for i in 0 to 7 loop
      in_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
    end loop;
    load_hi <= '0';

    -- Registerinhalte lesen & überprüfen...
    for i in 0 to 7 loop
      out0_sel <= std_logic_vector (to_unsigned (i, 3));
      out1_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
      assert out0_data = "1111111100000000" report "Load High funktioniert nicht bei out0";
      assert out1_data = "1111111100000000" report "Load High funktioniert nicht bei out1";
    end loop;

    -- jetzt Low-Bytes schreiben...
    in_data <= "0000101011111111";
    load_hi <= '0'; load_lo <= '1';
    for i in 0 to 7 loop
      in_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
    end loop;
    load_lo <= '0';

    -- Registerinhalte lesen & überprüfen...
    for i in 0 to 7 loop
      out0_sel <= std_logic_vector (to_unsigned (i, 3));
      out1_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
      assert out0_data = "1111111111111111" report "Load Low funktioniert nicht bei out0";
      assert out1_data = "1111111111111111" report "Load Low funktioniert nicht bei out1";
    end loop;


    testdata(0) <= "0000000000000001";
    testdata(1) <= "0000000000000010";
    testdata(2) <= "0000000000000100";
    testdata(3) <= "0000000000001000";
    testdata(4) <= "0000000000010000";
    testdata(5) <= "0000000000100000";
    testdata(6) <= "0000000001000000";
    testdata(7) <= "0000000010000000";

    run_cycle;
    -- jedes Register anders schreiben...
    in_data <= testdata(0);
    load_hi <= '1'; load_lo <= '1';
    for i in 0 to 7 loop
      in_data <= testdata(i);
      in_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
    end loop;
    load_lo <= '0';
    load_hi <= '0';

    -- Registerinhalte lesen & überprüfen...
    for i in 0 to 7 loop
      out0_sel <= std_logic_vector (to_unsigned (i, 3));
      out1_sel <= std_logic_vector (to_unsigned (i, 3));
      run_cycle;
      assert out0_data = testdata(i);
      assert out1_data = testdata(i);
    end loop;

    -- Print a note & finish simulation...
    assert false report "Simulation finished" severity note;
    wait;

  end process;

end TESTBENCH;
