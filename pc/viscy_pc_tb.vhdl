--Programmzähler Testbench
--Checkliste zur Testbench
--Funktioniert der Reset und dominiert er?
--Funktioniert das Laden?
--Funktioniert das Inkrementieren über die gesamte Wortbreite?
--Funktioniert das Halten von Werten?

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_TB is
end PC_TB;

architecture TESTBENCH of PC_TB is

	-- Component declaration
	component PC is
		port (clk, reset, inc, load: in std_logic;
			pc_in: in std_logic_vector(15 downto 0);
			pc_out: out std_logic_vector(15 downto 0));
	end component;
			
	-- configuration
	--RTL muss ggf. noch geändert werden
	for IMPL: PC use entity WORK.PC(RTL);
	
	--Internal signals
	signal clk, reset, inc, load: std_logic;
	signal pc_in, pc_out: std_logic_vector(15 downto 0);
	
	begin
	
		--Instantiate PC
		IMPL: PC port map (clk => clk, reset => reset, inc => inc, load => load, pc_in => pc_in, pc_out => pc_out);
		
		--Main process
		process
		
		--Prozedure muss vorhanden sein, wenn Taktsignal vorhanden sein soll
		procedure run_cycle is
			variable period: time := 10 ns;
			begin	
				clk <= '0';
			wait for period / 2;
					clk <= '1';
			wait for period /2;
		end procedure;
		
		begin
		
		--Funktioniert das Laden?
		--Möglichkeiten: load = 0/1 inc = 0/1
		--load = 1
		pc_in <= "1010101010101010"; load <= '1';
		run_cycle;
		assert pc_out = "1010101010101010" report "Test 1 - Laden fehlgeschlagen";
		
		--load = 1 und inc = 1
		pc_in <= "0101010101010101"; load <= '1'; inc <= '1';
		run_cycle;
		assert pc_out = "0101010101010101" report "Test 2 - Laden fehlgeschlagen";
		
		--load = 0 und inc = 0
		pc_in <= "0000000000000000"; load <= '0'; inc <= '0';
		run_cycle;
		assert pc_out = "0101010101010101" report "Test 3 - nicht Laden fehlgeschlagen";
		
		--Funktioniert das Inkrementieren über die gesamte Wortbreite?
		--Möglichkeiten: um 1 erhöhen; um 1 erhöhen mit load = 0/1
		reset <= '1'; load <= '0'; inc <= '0';
		run_cycle;
		
		--um 1 erhöhen
		inc <= '1'; reset <= '0';
		run_cycle;
		assert pc_out = "0000000000000001" report "Test 4 - Erhöhen fehlgeschlagen";
		
		--load = 0
		pc_in <= "1111111111111111"; inc <= '1';
		run_cycle;
		assert pc_out = "0000000000000010" report "Test 5 - Erhöhen fehlgeschlagen mit load = 0";
		
		--load = 1
		pc_in <= "1111111111111111"; load <= '1';
		run_cycle;
		assert pc_out = pc_in report "Test 6 - Erhöhen fehlgeschlagen mit load = 1";
		
		--Funktioniert das Halten von Werten?
		pc_in <= "1111111111111111"; load <= '1'; inc <= '0';
		run_cycle;
		pc_in <= "1111111111111111"; load <= '0'; inc <='0'; reset <= '0';
		for x in 0 to 5 loop
			run_cycle;
		end loop;
		assert pc_out = "1111111111111111" report "Test 7 - Halten hat nicht funktioniert";
		
		--Funktioniert der Reset und dominiert er?
		--Möglichkeiten: reset = 0/1
		--reset = 1 - dominieren
		reset <= '1'; load <= '1'; inc <= '1'; pc_in <= "1111111111111111";
		run_cycle;
		assert pc_out = "0000000000000000" report "Test 8 - Reset hat nicht funktioniert";
		
		--reset = 0
		pc_in <= "1111111111111111"; load <='1'; reset <= '0';
		run_cycle;
		assert pc_out = "1111111111111111" report "Test 9 - Reset durchgefuehrt, obwohl nicht gewollt";
		
		-- Print a note & finish simulation now
		assert false report "Simulation finished" severity note;
		wait;               -- end simulation
		
	end process;

end architecture;
