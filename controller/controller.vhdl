library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROLLER is
    port (
        clk, reset: in std_logic;
        ir: in std_logic_vector(15 downto 0); -- Befehlswort
        ready, zero: in std_logic; -- weitere Statussignale
        c_reg_ldmem, c_reg_ldi, -- Auswahl beim Register-Laden
        c_regfile_load_lo, c_regfile_load_hi, -- Steuersignale Reg.-File
        c_pc_load, c_pc_inc, -- Steuereingaenge PC
        c_ir_load, -- Steuereingang IR
        c_mem_rd, c_mem_wr, -- Signale zum Speicher
        c_adr_pc_not_reg : out std_logic -- Auswahl Adress-Quelle
    );
end CONTROLLER;

architecture RTL of CONTROLLER is
    -- Aufzählungstyp für den Zustand...
    type t_state is ( s_reset, s_if1, s_if2, s_id, s_alu, s_ldil, s_ldih);
    signal state, next_state: t_state;
begin 
    -- Zustandsregister (taktsynchroner Prozess) ...
    process (clk) -- (nur) Taktsignal in Sensitivitätsliste
    begin
        if rising_edge (clk) then
            if reset = '1' then 
                state <= s_reset; -- Reset hat Vorrang!
            else 
                state <= next_state;
            end if;
        end if;
    end process;

    -- Prozess für die Übergangs- und Ausgabefunktion...
    process (state, ready, zero, ir) -- Zustand und alle Status-Signale in Sensitiviätsliste
    begin

        -- Default-Werte für alle Ausgangssignale...
        c_regfile_load_lo <= '0';
        c_regfile_load_hi <= '0';
        c_adr_pc_not_reg <= '-'; -- Don't Care

        -- Zustandsabhängige Belegung ...
        -- Hier steht die eigentliche Automaten-Logik.
        -- Es müssen nur Abweichungen von der Default-Belegung behandelt werden.
        case state is
            when s_reset =>
                next_state <= s_if1;

            when s_if1 =>
                if ready = '0' then next_state <= s_if2; end if;

            when s_if2 =>
            -- Zustandsänderungen dürfen mit Bedingungen verknüpft sein,
            -- Zuweisungen an Steuersignale nicht!
            if ready = '1' then next_state <= s_id; end if;
            c_adr_pc_not_reg <= '1';
            c_mem_rd <= '1';
            c_ir_load <= '1';

            when s_id =>
                c_pc_inc <= '1';
            
            when s_alu =>
            when s_ldil =>
            when s_ldih =>
                c_pc_inc <= '1';

            when others => null;
        end case;
    end process;
      
end RTL;