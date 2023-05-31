library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Define ALU entity
entity VISCY_ALU is
    port (
        a: in std_logic_vector (15 downto 0);  -- 16-bit input a
        b: in std_logic_vector (15 downto 0);  -- 16-bit input b
        sel: in std_logic_vector (2 downto 0); -- 3-bit operation selector
        y: out std_logic_vector (15 downto 0); -- 16-bit output
        zero: out std_logic                    -- 0 output (helper for conditional jumps)
    );
end VISCY_ALU;

-- RTL behavior architecture
architecture RTL of VISCY_ALU is
begin
    process (a, b, sel)
    begin
        -- Set zero helper to 1 if b = 0x16 (literal)
        if b = "0000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
        -- Perform selected operation
        case sel is
            when "000" => y <= std_logic_vector(unsigned(a) + unsigned(b)); -- add a and b
            when "001" => y <= std_logic_vector(unsigned(a) - unsigned(b)); -- sub b from a
            when "010" => y <= a(14 downto 0) & '0';                        -- arithmetic left shift (for a)
            when "011" => y <= a(15) & a(15 downto 1);                      -- arithmetic right shift (for a)
            when "100" => y <= a AND b;                                     -- a AND b
            when "101" => y <= a OR b;                                      -- a OR b
            when "110" => y <= a XOR b;                                     -- a XOR b
            when "111" => y <= NOT a;                                       -- NOT a
            when others => y <= "0000000000000000";                         -- TODO: good default?
        end case;
    end process;
end RTL;
