library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VISCY_CONTROLLER is
	port (
		clk, reset: in std_logic;
		ir: in std_logic_vector(15 downto 0); 	-- Befehlswort / Opcode
		ready, zero: in std_logic; 				-- weitere Statussignale
		c_reg_ldmem, c_reg_ldi, 				-- Auswahl beim Register-Laden
		c_regfile_load_lo, c_regfile_load_hi, 	-- Steuersignale Reg.-File
		c_pc_load, c_pc_inc, 					-- Steuereingaenge PC
		c_ir_load, 								-- Steuereingang IR
		c_mem_rd, c_mem_wr, 					-- Signale zum Speicher
		c_adr_pc_not_reg : out std_logic 		-- Auswahl Adress-Quelle
	);
end VISCY_CONTROLLER;


architecture RTL of VISCY_CONTROLLER is
	-- Aufzählungstyp für den Zustand...
	type t_state is ( s_reset, s_if1, s_if2, s_id, s_alu, s_ldil, 
		s_ldih, s_halt, s_error);
	signal state, next_state: t_state;
begin

	-- Zustandsregister (taktsynchroner Prozess) ...
	process (clk) -- (nur) Taktsignal in Sensitivitätsliste
	begin
		if rising_edge (clk) then
			if reset = '1' then state <= s_reset; -- Reset hat Vorrang!
			else state <= next_state;
			end if;
		end if;
	end process;
	
	-- Prozess für die Uebergangs- und Ausgabefunktion...
	process (state, ready, zero, ir) -- Zustand und alle Status-Signale in Sensitiviaetsliste
	begin
		-- Default-Werte für alle Ausgangssignale... => Latches verhindern
		c_reg_ldmem <= '0';
		c_reg_ldi <= '0';
		c_regfile_load_lo <= '0';
		c_regfile_load_hi <= '0';
		c_pc_load <= '0';			-- only used for jump statements
		c_pc_inc <= '0';
		c_ir_load <= '0';
		c_mem_rd <= '0';
		c_mem_wr <= '0';
		c_adr_pc_not_reg <= '-'; 	-- Don't Care
		
		-- prevent latch, error if no next state is assigned
		next_state <= s_error;
		
		-- Zustandsabhängige Belegung ...
		-- Hier steht die eigentliche Automaten-Logik.
		-- Es müssen nur Abweichungen von der Default-Belegung behandelt werden.
		case state is
			when s_reset =>
				next_state <= s_if1;
			when s_if1 =>
				if ready = '0' then 
					next_state <= s_if2;
				else
					next_state <= s_if1;
				end if;
			when s_if2 =>
				-- Zustandsänderungen dürfen mit Bedingungen verknüpft sein,
				-- Zuweisungen an Steuersignale nicht!
				if ready = '1' then 
					next_state <= s_id;
				else
					next_state <= s_if2;
				end if;
				c_adr_pc_not_reg <= '1';
				c_mem_rd <= '1';
				c_ir_load <= '1';
			when s_id =>
				c_pc_inc <= '1';
				case ir(15 downto 14) is
					when "00" => 
						next_state <= s_alu;
					when "10" =>
						if ir(12 downto 11) = "01" then
							next_state <= s_halt;
						end if;
					when "01" =>
						if ir(12 downto 11) = "00" then
							next_state <= s_ldil;
						elsif ir(12 downto 11) = "01" then
							next_state <= s_ldih;
						end if;
					when others => null;
				end case;
			when s_alu =>
				next_state <= s_if1;
				c_regfile_load_lo <= '1';
                c_regfile_load_hi <= '1';
			when s_ldil =>
				next_state <= s_if1;
				c_regfile_load_lo <= '1';
				c_reg_ldi <= '1';
			when s_ldih => 
				next_state <= s_if1;
				c_regfile_load_hi <= '1';
				c_reg_ldi <= '1';
			when s_error => next_state <= s_error;
			when s_halt => next_state <= s_halt;
			when others => null;
		end case;
	end process;

end RTL;
