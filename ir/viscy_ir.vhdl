library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VISCY_IR is
port (
    clk: in std_logic;
    load: in std_logic; -- Steuersignal
    ir_in: in std_logic_vector (15 downto 0); -- Dateneingang
    ir_out: out std_logic_vector (15 downto 0) -- Datenausgang
);
end VISCY_IR;

architecture RTL of VISCY_IR is
    signal instr_reg: std_logic_vector(15 downto 0);
begin  

    -- Output
    ir_out <= instr_reg;
    -- State Machine
    process (clk)
    begin
        if rising_edge(clk) then
            if(load = '1') then
                instr_reg <= ir_in;
            end if;
        end if;
end process;
    
end RTL;