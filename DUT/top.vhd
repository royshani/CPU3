LIBRARY ieee; -- Import IEEE standard logic library
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all; -- Import component declarations from aux_package

-------------------------------------
ENTITY top IS
-- Top-level entity for integrating Datapath and Control units

generic(
    Dwidth      : integer := 16; -- Data width
    Awidth      : integer := 6;  -- Address width (2^6 = 64 locations)
    dept        : integer := 64; -- Depth of memory
    StateLength : integer := 5   -- Number of bits to represent FSM states
);
port(
    clk_i              : in std_logic;  -- Clock signal fed from TB
    rst_i              : in std_logic;  -- Reset signal fed from TB
    ena_i              : in std_logic;  -- Enable signal for control unit fed from TB
    done_o             : out std_logic_vector(1 downto 0) := "00", -- Done flag to TB

    data_in_i          : in std_logic_vector(Dwidth-1 downto 0);        -- write content into ProgMem, from TB through top
    prog_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);        -- write address into ProgMem, from TB through top
    prog_wr_en_i       : in std_logic;                                  -- enable bit to write into ProgMem, from TB through top
    tb_active_i        : in std_logic;                                  -- enable bit to write from TB instead of internally
    data_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);        -- write address into DataMem, from TB through top
    data_wr_data_i     : in std_logic_vector(Dwidth-1 downto 0);        -- write data into DataMem, from TB through top
    data_wr_en_i       : in std_logic;                                  -- enable bit to write into DataMem, from TB through top
    data_rd_data_o     : out std_logic_vector(Dwidth-1 downto 0);       -- read data from DataMem, from TB through top
    data_rd_addr_i     : in std_logic_vector(Awidth-1 downto 0)         -- write address into DataMem, from TB through top
);
END top;

ARCHITECTURE topArch OF top IS 

    -- Signals from Datapath to Control (flags and opcode)
    signal alu_c_o, alu_z_o, alu_n_o : std_logic;                    -- ALU flags: carry, zero, negative
    signal opcode_o                  : std_logic_vector(3 downto 0); -- Opcode extracted from instruction

    -- Control signals sent to Datapath
    signal RF_out_i, data_mem_out_i, Cout_i     : std_logic; -- Bus control enable signals
    signal Imm2_in_i, Imm1_in_i, IRin_i         : std_logic; -- Immediate and instruction register control
    signal RF_addr_i, PCsel_i                   : std_logic_vector(1 downto 0); -- RF multiplexer and PC selection
    signal RF_WregEn_i, RF_rst_i                : std_logic; -- Register file control
    signal Ain_i, Cin_i, Mem_in_i               : std_logic; -- Register enables and memory address latch
    signal data_MemEn_i, PCin_i                 : std_logic; -- Data memory and PC write enables
    signal ALU_op_i                             : std_logic_vector(2 downto 0); -- ALU operation code

    signal status_bits_r                        : std_logic_vector(12 downto 0); -- Control unit status outputs

BEGIN

    -- Datapath Instantiation
    mapDatapath: Datapath generic map(Dwidth, Awidth, dept) port map(
        clk_i, data_in_i, prog_wr_addr_i, prog_wr_en_i, tb_active_i,
        data_wr_addr_i, data_wr_data_i, data_wr_en_i, data_rd_data_o, data_rd_addr_i,
        alu_c_o, alu_z_o, alu_n_o, opcode_o,
        RF_out_i, data_mem_out_i, Cout_i, Imm2_in_i, Imm1_in_i, IRin_i,
        RF_addr_i, PCsel_i, RF_WregEn_i, RF_rst_i, Ain_i, Cin_i, Mem_in_i,
        data_MemEn_i, PCin_i, ALU_op_i
    );

    -- Control Unit Instantiation
    mapControl: Control generic map(StateLength) port map(
        clk_i, rst_i, ena_i,                          -- Clock, reset, enable
        alu_c_o, alu_z_o, alu_n_o, opcode_o,          -- ALU flags and opcode
        RF_out_i, data_mem_out_i, Cout_i,             -- Bus control signals
        Imm2_in_i, Imm1_in_i, IRin_i,                 -- IR and immediate control
        RF_addr_i, PCsel_i, RF_WregEn_i, RF_rst_i,    -- RF controls
        Ain_i, Cin_i, Mem_in_i,                       -- Register and address latch
        data_MemEn_i, PCin_i, ALU_op_i,               -- Memory/PC/ALU control
        status_bits_r                                 -- Status bits output
    );

    -- Assign DONE signal from Control Unit status bits
    done_o(0) <= status_bits_r(8); -- 'done' flag for external monitoring

END topArch;