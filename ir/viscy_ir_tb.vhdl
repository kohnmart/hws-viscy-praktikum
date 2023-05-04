library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity VISCY_IR_TB is
end VISCY_IR_TB;


architecture TESTBENCH of VISCY_IR_TB is

  -- Component declaration ...
  component IR
    port ( clk: in std_logic;
      load: in std_logic; -- Steuersignal
      ir_in: in std_logic_vector (15 downto 0); -- Dateneingang
      ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
    );
  end component;

  -- Clock period ...
  constant period: time := 10 ns;

  -- Signals ...
  signal clk, load: std_logic;
  signal ir_in, ir_out: std_logic_vector(15 downto 0);

begin

  -- Instantiate regfile ...
  U_IR : IR port map (
    clk => clk, 
    load => load,
    ir_in => ir_in,
    ir_out => ir_out
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

    -- Instruction wird korrekt geladen
    run_cycle;
    ir_in <= "0000111100001111";
    load <= '1';
    run_cycle;
    assert ir_out = "0000111100001111";
    -- Instruction wird gehalten wenn load 0
    ir_in <= "1111000011110000";
    load <= '0';
    run_cycle;
    assert ir_out = "0000111100001111";
    -- Instruction wird bei erneutem load=1 korrekt geladen
    ir_in <= "1010000010100000";
    load <= '1';
    run_cycle;
    assert ir_out = "1010000010100000";

    -- Print a note & finish simulation...
    assert false report "Simulation finished" severity note;
    wait;

  end process;

end TESTBENCH;
