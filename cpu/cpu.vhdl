library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CPU is 
port (
    -- clk/reset 
    -- adress
    -- data
    -- read/write
    -- ready
);
end CPU;


architecture RTL of CPU is

    -- internal signals
    -- ALU
    signal alu_y: std_logic_vector(15 downto 0);
    signal alu_zero: std_logic;
    
    -- PC
    signal pc_out: std_logic_vector(15 downto 0);
    
    -- IR
    signal ir_out: std_logic_vector(15 downto 0);
   
    -- REGFILE
    signal regfile_out0_data, regfile_out1_data, regfile_in_data: STD_LOGIC_VECTOR (15 downto 0);
   
    -- Controller 
    -- ??
   
    -- Memory
    signal mem_data_in, mem_data_out: std_logic_vector (15 downto 0);

    -- ALU
    component ALU is
        port(
            a: in std_logic_vector(15 downto 0);
            b: in std_logic_vector(15 downto 0);
            sel: in std_logic_vector(2 downto 0);
            y: out std_logic_vector(15 downto 0);
            zero: out std_logic;
        );
    end component;
    
    -- PC
    component PC is 
    port (
        clk: in std_logic;
        reset, inc, load: in std_logic;
        pc_in: in std_logic_vector(15 downto 0);
        pc_out: in std_logic_vector(15 downto 0);
    );
    end component;

    -- IR
    component IR is 
    port(
        clk: in std_logic;
        load: in std_logic;
        ir_in: in std_logic_vector(15 downto 0);
        ir_out: out std_logic_vector(15 downto 0);
    );
    end component;

    -- REGFILE
    component REGFILE is 
    port(
        clk: in std_logic;
        out0_data: out std_logic_vector (15 downto 0);
        out0_sel: in std_logic_vector (2 downto 0); 
        out1_data: out std_logic_vector (15 downto 0);
        out1_sel: in std_logic_vector (2 downto 0);
        in_data: in std_logic_vector (15 downto 0);
        in_sel: in std_logic_vector (2 downto 0); 
        load_lo, load_hi: in std_logic
    );    
    end component;

    -- Controller ??


    -- Konfiguration
    for all: ALU use entity WORK.ALU(RTL);
    for all: CONTROLLER use entity WORK.CONTROLLER(RTL);
    for all: IR use entity WORK.IR(RTL);
    for all: PC use entity WORK.PC(RTL);
    for all: REGFILE use entity WORK.REGFILE(RTL);

    begin 

        -- Port Mapping

        -- ALU
        CPU_ALU: ALU port map (
            a => regfile_out0_data,
            b => regfile_out1_data,
            y => alu_y,
            sel => ir_out(13 downto 11),
            zero => alu_zero
        );


        -- PC
        CPU_PC: PC port map (
            clk => clk,
            reset => reset,
            inc => c_pc_inc,
            load => c_pc_load,
            pc_in => regfile_out0_data,
            pc_out => pc_out
        );

        -- REGFILE
        CPU_REGFILE: REGFILE port map (
            clk => clk,
            in_data => regfile_in_data,
            in_sel => ir_out(10 downto 8),
            out0_data => regfile_out0_data,
            out0_sel => ir_out(7 downto 5),
            out1_data => regfile_out1_data,
            out1_sel => ir_out(4 downto 2),
            load_lo => c_regfile_load_lo,
            load_hi => c_regfile_load_hi
        );

        -- IR 
        CPU_IR: IR port map (
            clk => clk,
            load => c_ir_load,
            ir_in => mem_data_in,
            ir_out => ir_out
        );


    -- Multiplexer Adress
    -- Selects from:
        -- PC
        -- REGFILE based on control signal
    -- Assigns to:
        -- adr-signal
     process (pc, regfile_out0_data, c_adr_pc_not_reg)
        begin
            if c_adr_pc_not_reg = '1' then adr <= pc; 
            -- changes in PC => output_value => subsequent adr for cpu ops
            else adr <= regfile_out0_data;
             -- changes in REGFILE => output_value => subsequent adr for cpu ops
            end if;
        end process;
        

        
    -- Multiplexer REGFILE
    -- Selects from:
        -- value from instruction_register
        -- data from memory
        -- ALU result based on control signal
    -- Assigns to:
        -- reg_file_in_data signal (input of REGFILE)
    process (c_reg_ldi, c_reg_ldmem, alu_y, mem_data_in, ir_out)
    begin
        if c_reg_ldi = '1' then -- load immediate op
            regfile_in_data <= ir_out (7 downto 0) & ir_out (7 downto 0); -- it-self-concatenation (16-bit)
            -- value from instruction_register is loaded into REGFILE

        elsif c_reg_ldmem = '1' then -- load from memory op
            regfile_in_data <= mem_data_in;
            -- data from memory is loaded into REGFILE

        elsif not (c_reg_ldi and c_reg_ldmem) = '1' then -- indicating ALU result is loaded into REGFILE
            regfile_in_data <= alu_y;
        end if;
    end process;



    -- Multiplexer MEMORY
    -- Select: 
        -- data coming from memory (write) 
        -- invalid (read)
    -- Assigns to:
        -- data (input of memory)
    process (mem_data_out, c_mem_wr) 
    begin
        if c_mem_wr = '1' then -- indicating write op
            data <= mem_data_out; -- mem_data_out value -> data_signal 
            -- data coming from memory will be assigned to data_signal
            -- connected to the input of the memory unit
            
            else -- indicating read
            data <= "ZZZZZZZZZZZZZZZZ";  -- invalid/dont care - statement (read-cycle)
        end if;
    end process;



    -- DATA FLOW --> Memory Operations
    mem_data_in <= data; -- write to memory data input
    rd <= c_mem_rd; --  c_mem_rd value controls read operations of the memory
    wr <= c_mem_wr; -- c_mem_wr value controls write operations of the memory

    end RTL;