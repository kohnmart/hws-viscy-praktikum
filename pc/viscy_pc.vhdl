library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Define Program Counter entity 
entity VISCY_PC is 
    port(
        clk : in std_logic;                         -- input clock_rate
        reset, inc, load : in std_logic;            -- input controll signals
        pc_in : in std_logic_vector(15 downto 0);   -- 16-bit input data
        pc_out : out std_logic_vector(15 downto 0)  -- 16-bit output counter
        );
end VISCY_PC;

architecture RTL of VISCY_PC is 
    signal count: unsigned (15 downto 0);           -- stores current value of pc
    begin 
        pc_out <= std_logic_vector(count);          -- assign count to pc_out
    process (clk, reset, inc, load, pc_in)          -- sequential process
        begin 
        if rising_edge(clk) then                    -- execution on rising edge
                if(reset = '1') then                -- check => reset-signal active?
                    count <= "0000000000000000";    -- assign zero 16-bit to count
                else 
                    if(inc = '1') then              -- check => increment-signal active?
                        count <= count + 1;         -- incremenct count-signal
                        end if;
                    if(load = '1') then             -- check => load-signal active?
                        count <= unsigned(pc_in);   -- assign converted pc_in to count 
                                                    -- jump to new 16-bit-address and load
                    end if;
                end if;
            end if;
        end process; 
end RTL;