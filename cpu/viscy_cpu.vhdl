library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VISCY_CPU is
    port (
        clk, reset: in std_logic;                   -- clock and reset
        adr: out std_logic_vector (15 downto 0);    -- adressbus
        rdata: in std_logic_vector (15 downto 0);   -- read-databus
        wdata: out std_logic_vector (15 downto 0);   -- write-databus
        rd, wr: out std_logic;                      -- read/write operations
        ready: in std_logic                         -- callback read/write
    );
end VISCY_CPU;

architecture RTL of VISCY_CPU is

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
    signal c_pc_load, c_pc_inc: std_logic;
    signal c_ir_load: std_logic;
    signal c_regfile_load_lo, c_regfile_load_hi: std_logic;
    signal c_reg_ldmem ,c_reg_ldi: std_logic;
    signal c_adr_pc_not_reg: std_logic;
    signal c_mem_rd, c_mem_wr: std_logic;
   
    -- Memory
    signal mem_data_in, mem_data_out: std_logic_vector (15 downto 0);

    -- ALU
    component VISCY_ALU is
        port(
            a: in std_logic_vector(15 downto 0);
            b: in std_logic_vector(15 downto 0);
            sel: in std_logic_vector(2 downto 0);
            y: out std_logic_vector(15 downto 0);
            zero: out std_logic
        );
    end component;
    
    -- PC
    component VISCY_PC is 
    port (
        clk: in std_logic;
        reset, inc, load: in std_logic;
        pc_in: in std_logic_vector(15 downto 0);
        pc_out: out std_logic_vector(15 downto 0)
    );
    end component;

    -- IR
    component VISCY_IR is 
    port(
        clk: in std_logic;
        load: in std_logic;
        ir_in: in std_logic_vector(15 downto 0);
        ir_out: out std_logic_vector(15 downto 0)
    );
    end component;

    -- REGFILE
    component VISCY_REGFILE is 
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

    -- Controller
    component VISCY_CONTROLLER is 
    port(
        clk, reset: in std_logic;
        ir: in std_logic_vector(15 downto 0);   -- operation
        ready, zero: in std_logic;              -- status signals
        c_reg_ldmem, c_reg_ldi,                 -- Auswahl beim Register-Laden
        c_regfile_load_lo, c_regfile_load_hi,    -- Controllsignals Regfile
        c_pc_load, c_pc_inc,                    -- Controllinput PC
        c_ir_load,                               -- Controllinput IR
        c_mem_rd, c_mem_wr,                      -- Storesignals 
        c_adr_pc_not_reg : out std_logic        -- Select adr source
       );
    end component; 
        
    -- configuration of entities
    for all: VISCY_ALU use entity WORK.VISCY_ALU(RTL);
    for all: VISCY_IR use entity WORK.VISCY_IR(RTL);
    for all: VISCY_PC use entity WORK.VISCY_PC(RTL);
    for all: VISCY_REGFILE use entity WORK.VISCY_REGFILE(RTL);
    for all: VISCY_CONTROLLER use entity WORK.VISCY_CONTROLLER(RTL); --- awaiting controller 


    begin 

        ----- PORT MAPPING -----

        -- ALU
        CPU_ALU: VISCY_ALU port map (
            a => regfile_out0_data,
            b => regfile_out1_data,
            y => alu_y,
            sel => ir_out(13 downto 11),
            zero => alu_zero
        );


        -- PC
        CPU_PC: VISCY_PC port map (
            clk => clk,
            reset => reset,
            inc => c_pc_inc,
            load => c_pc_load,
            pc_in => regfile_out0_data,
            pc_out => pc_out
        );

        -- REGFILE
        CPU_REGFILE: VISCY_REGFILE port map (
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
        CPU_IR: VISCY_IR port map (
            clk => clk,
            load => c_ir_load,
            ir_in => mem_data_in,
            ir_out => ir_out
        );
        
        -- CONTROLLER
        CPU_CONTROLLER: VISCY_CONTROLLER port map (
		    clk => clk,
            reset => reset,
		    ir => ir_out, 	
		    ready => ready,
            zero => alu_zero, 				
		    c_reg_ldmem => c_reg_ldmem, 
            c_reg_ldi => c_reg_ldi, 			
		    c_regfile_load_lo => c_regfile_load_lo, 
            c_regfile_load_hi => c_regfile_load_hi,  	
		    c_pc_load => c_pc_load, 
            c_pc_inc => c_pc_inc, 					
		    c_ir_load => c_ir_load, 								
		    c_mem_rd => c_mem_rd, 
            c_mem_wr => c_mem_wr, 					
		    c_adr_pc_not_reg => c_adr_pc_not_reg
        );
    
    -------- DATA ROUTING --------

    -- Multiplexer ADRESS
    -- Selects from:
        -- PC
        -- REGFILE based on control signal
    -- Assigns to:
        -- adr-signal
     process (pc_out, regfile_out0_data, c_adr_pc_not_reg)
        begin
            if c_adr_pc_not_reg = '1' then adr <= pc_out; 
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
            wdata <= mem_data_out; -- mem_data_out value -> data_signal 
            -- data coming from memory will be assigned to data_signal
            -- connected to the input of the memory unit
            
        else -- indicating read
            wdata <= "ZZZZZZZZZZZZZZZZ";  -- invalid/dont care - statement (read-cycle)
        end if;
    end process;



    -- DATA FLOW --> Memory Operations
    mem_data_in <= rdata; -- write to memory data input
    rd <= c_mem_rd; --  c_mem_rd value controls read operations of the memory
    wr <= c_mem_wr; -- c_mem_wr value controls write operations of the memory
    --- wdata <= regfile_out1_data; --wdata 

    end RTL;
