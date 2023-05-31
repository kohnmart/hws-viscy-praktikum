library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; -- Needed for shifts


entity VISCY_ALU_TB is
end VISCY_ALU_TB;


architecture TESTBENCH of VISCY_ALU_TB is

	-- Component declaration...
	component VISCY_ALU
		port ( 
			a : in std_logic_vector (15 downto 0);  -- Eingang A
			b : in std_logic_vector (15 downto 0);  -- Eingang B 
			sel : in std_logic_vector (2 downto 0); -- Operation 
			y : out std_logic_vector (15 downto 0); -- Ausgang 
			zero: out std_logic -- gesetzt, falls Eingang B = 0
		);
	end component;
	
	-- Configuration...
	for IMPL: VISCY_ALU use entity WORK.VISCY_ALU(RTL);
	
	-- Internal signals...
	signal a_impl, b_impl, y_impl: std_logic_vector (15 downto 0);
	signal sel_impl: std_logic_vector (2 downto 0);
	signal zero_impl: std_logic;
	
begin

	IMPL: VISCY_ALU port map (a => a_impl, b => b_impl, sel => sel_impl, y => y_impl, zero => zero_impl);

	process
		constant wait_time: time := 1 ns; -- is there a critical time?
		
		-- for random number generation
		constant prime_number: signed (15 downto 0) := TO_SIGNED(97, 16);
		variable rnd_a: signed (15 downto 0) := TO_SIGNED(5, 16);
		variable rnd_b: signed (15 downto 0) := TO_SIGNED(7, 16);
	
		procedure run_all_operations(a, b: in std_logic_vector (15 downto 0)) is -- in, inout or out? Name variables differently?
			variable y: std_logic_vector (15 downto 0);
		begin
			-- Check if input is valid
			if (IS_X(a) or IS_X(b)) then
				assert false report "Invalid input to procedure run_all_operations" severity note;
				return;
			end if;
		
			a_impl <= a; b_impl <= b;
		
			-- add
			y := std_logic_vector(signed(a) + signed(b)); -- signed or unsigned?
			sel_impl <= "000";
			wait for wait_time;
			assert y_impl = y report "Addition failed!";
			-- sub
			y := std_logic_vector(signed(a) - signed(b)); -- signed or unsigned?
			sel_impl <= "001";
			wait for wait_time;
			assert y_impl = y report "Subtraction failed!";
			-- sal (shift arithmetic left)
			y := std_logic_vector(shift_left(signed(a), 1)); -- signed means arithmetic shift
			sel_impl <= "010";
			wait for wait_time;
			assert y_impl = y report "Shift arithmetic left failed!";
			-- sar (shift arithmetic right)
			y := std_logic_vector(shift_right(signed(a), 1)); -- signed means arithmetic shift
			sel_impl <= "011";
			wait for wait_time;
			assert y_impl = y report "Shift arithmetic right failed!";
			-- and
			y := a AND b;
			sel_impl <= "100";
			wait for wait_time;
			assert y_impl = y report "AND-Operation failed!";
			-- or
			y := a OR b;
			sel_impl <= "101";
			wait for wait_time;
			assert y_impl = y report "OR-Operation failed!";
			-- xor
			y := a XOR b;
			sel_impl <= "110";
			wait for wait_time;
			assert y_impl = y report "XOR-Operation failed!";
			-- not
			y := NOT(a);
			sel_impl <= "111";
			wait for wait_time;
			assert y_impl = y report "NOT-Operation failed!";
		end procedure;
	begin
		-- Check port zero
		assert false report "Check port zero" severity note;
		a_impl <= "0000000000000000"; b_impl <= "0000000000000000";
		wait for wait_time;
		assert zero_impl = '1' report "Port zero should be 1";
		
		a_impl <= "0000000000000000"; b_impl <= "0000000000000001";
		wait for wait_time;
		assert zero_impl = '0' report "Port zero should be 0";
		
		a_impl <= "0000000000000001"; b_impl <= "0000000000000000";
		wait for wait_time;
		assert zero_impl = '1' report "Port zero should be 1";
		
		a_impl <= "0000000000000001"; b_impl <= "0000000000000001";
		wait for wait_time;
		assert zero_impl = '0' report "Port zero should be 0";
		
		
		-- Check if arithmetic left shift works (identical to left logical shift)
		assert false report "Check arithmetic left shift" severity note;
		sel_impl <= "010";
		a_impl <= "1011001110110011";
		wait for wait_time;
		assert y_impl = "0110011101100110" 
			report "Arithmetic left shift does not work";
			
		sel_impl <= "010";
		a_impl <= "1011001110110010";
		wait for wait_time;
		assert y_impl = "0110011101100100" 
			report "Arithmetic left shift does not work";
		
		
		-- Check if arithmetic right shift works (different from right logical shift)
		assert false report "Check arithmetic right shift" severity note;
		sel_impl <= "011";
		a_impl <= "1011001110110011";
		wait for wait_time;
		assert y_impl = "1101100111011001" 
			report "Arithmetic right shift does not work";
			
		sel_impl <= "011";
		a_impl <= "0011001110110010";
		wait for wait_time;
		assert y_impl = "0001100111011001" 
			report "Arithmetic right shift does not work";
		
		
		-- Check if carry works low
		run_all_operations("0000000000000001", "0000000000000001");
		wait for wait_time;
		-- Check if carry works high
		run_all_operations("0100000000000000", "0100000000000000");
		wait for wait_time;
		-- Check if carry works low and high
		run_all_operations("0100000000000001", "0100000000000001");
		wait for wait_time;

		run_all_operations("0101010101010101", "1010101010101010");
		wait for wait_time;
		
		
		-- (Pseudo-)random inputs
		-- Use prime numbers
		assert false report "Check with random numbers" severity note;
		for n in 1 to 10 loop
			-- Multiplication doubles length of std vector -> bounds overflow
			-- Resize to 16 bits, function RESIZE returns signed
			rnd_a := RESIZE(rnd_a * prime_number, 16);
			rnd_b := RESIZE(rnd_b * prime_number, 16);
			
			run_all_operations(std_logic_vector(rnd_a), std_logic_vector(rnd_b));
			wait for wait_time;
		end loop;
		
		-- Finish simulation now
		assert false report "Simulation finished" severity note;
		wait; -- end simulation
	
	end process;

end architecture;
