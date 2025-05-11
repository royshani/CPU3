library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;

--------------------------------------------------------------
-- Datapath: Core processing block of the CPU
-- Handles instruction fetch, decode, execution, memory access, and register writeback
--------------------------------------------------------------

entity Datapath is
    generic(
        Dwidth : integer := 16; -- Data width (e.g., 16 bits)
        Awidth : integer := 6;  -- Address width (e.g., 64 locations)
        dept   : integer := 64  -- Memory depth
    );
    port(
        -- Clock and testbench inputs
        clk_i              : in std_logic;
        data_in_i          : in std_logic_vector(Dwidth-1 downto 0); -- Instruction memory input
        prog_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);
        prog_wr_en_i       : in std_logic;
        tb_active_i        : in std_logic;

        -- Data memory testbench access
        data_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);
        data_wr_data_i     : in std_logic_vector(Dwidth-1 downto 0);
        data_wr_en_i       : in std_logic;
        data_rd_data_o     : out std_logic_vector(Dwidth-1 downto 0);
        data_rd_addr_i     : in std_logic_vector(Awidth-1 downto 0);

        -- Flags to ControlUnit
        alu_c_o            : out std_logic;
        alu_z_o            : out std_logic;
        alu_n_o            : out std_logic;
        opcode_o           : out std_logic_vector(3 downto 0);

        -- Control signals from ControlUnit
        RF_out_i           : in std_logic; -- Register file output enable
        data_mem_out_i     : in std_logic; -- Data memory output enable
        Cout_i             : in std_logic;
        Imm2_in_i          : in std_logic;
        Imm1_in_i          : in std_logic;
        IRin_i             : in std_logic;
        RF_addr_i          : in std_logic_vector(1 downto 0);
        PCsel_i            : in std_logic_vector(1 downto 0);
        RF_WregEn_i        : in std_logic;
        RF_rst_i           : in std_logic;
        Ain_i              : in std_logic;
        Cin_i              : in std_logic;
        Mem_in_i           : in std_logic;
        data_MemEn_i       : in std_logic;
        PCin_i             : in std_logic;
        ALU_op_i           : in std_logic_vector(2 downto 0)
    );
end Datapath;

architecture DataArch of Datapath is

    -- Internal signals for inter-module connections
    signal rf_addr_mux_r            : std_logic_vector(3 downto 0); -- Selected RF address
    signal imm1_ext_r, imm2_ext_r   : std_logic_vector(Dwidth-1 downto 0); -- Sign-extended immediates
    signal imm_pc_r                 : std_logic_vector(7 downto 0); -- Immediate for PC logic
    signal pc_addr_r                : std_logic_vector(Awidth-1 downto 0); -- PC output address
    signal instr_r                  : std_logic_vector(Dwidth-1 downto 0); -- Instruction fetched
    signal bus_r                    : std_logic_vector(Dwidth-1 downto 0); -- Shared bus
    signal rf_data_r                : std_logic_vector(Dwidth-1 downto 0); -- RF output
    signal reg_a_q                  : std_logic_vector(Dwidth-1 downto 0); -- Register A output
    signal alu_result_r             : std_logic_vector(Dwidth-1 downto 0); -- ALU result
    signal mem_wr_en_mux_r          : std_logic; -- TB vs CPU memory enable
    signal mem_wr_data_mux_r        : std_logic_vector(Dwidth-1 downto 0); -- TB vs CPU memory write data
    signal mem_wr_addr_mux_r        : std_logic_vector(Awidth-1 downto 0); -- TB vs CPU write address
    signal mem_rd_addr_mux_r        : std_logic_vector(Awidth-1 downto 0); -- TB vs CPU read address
    signal mem_out_r                : std_logic_vector(Dwidth-1 downto 0); -- Data memory output
    signal reg_dff_out_q            : std_logic_vector(Dwidth-1 downto 0); -- Memory address latch

begin

    -- Instruction Register
    mapIR: IR generic map(Dwidth) port map(
        clk => clk_i,
        ena => IRin_i,
        rst => RF_rst_i,
        RFaddr_rd_i => RF_addr_i,
        RFaddr_wr_i => RF_addr_i,
        i_IR_content => instr_r,
        o_OPCODE => opcode_o,
        o_addr => rf_addr_mux_r,
        o_signext1 => imm1_ext_r,
        o_signext2 => imm2_ext_r,
        o_imm_to_PC => imm_pc_r
    );

    -- Program Memory: fetch instruction based on PC
    mapProgMem: ProgMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk_i,
        memEn => prog_wr_en_i,
        WmemData => data_in_i,
        WmemAddr => prog_wr_addr_i,
        RmemAddr => pc_addr_r,
        RmemData => instr_r
    );

    -- PC logic: determines next instruction address
    mapPC: PCLogic generic map(Awidth) port map(
        clk => clk_i,
        i_PCin => PCin_i,
        i_PCsel => PCsel_i,
        i_IR_imm => imm_pc_r,
        o_currentPC => pc_addr_r
    );

    -- Register File: 2R1W RF
    mapRegisterFile: RF port map(
        clk => clk_i,
        rst => RF_rst_i,
        WregEn => RF_WregEn_i,
        WregData => alu_result_r,
        RregAddr => rf_addr_mux_r,
        WregAddr => rf_addr_mux_r,
        RregData => rf_data_r
    );

    -- ALU: executes arithmetic and logic ops
    mapALU: ALU_main generic map(Dwidth) port map(
        reg_a_out => reg_a_q,
        reg_b_in => bus_r,
        ALU_op => ALU_op_i,
        result => alu_result_r,
        C => alu_c_o,
        N => alu_n_o,
        Z => alu_z_o
    );

    -- Data Memory
    mapDataMem: dataMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk_i,
        memEn => mem_wr_en_mux_r,
        WmemData => mem_wr_data_mux_r,
        WmemAddr => mem_wr_addr_mux_r,
        RmemAddr => mem_rd_addr_mux_r,
        RmemData => mem_out_r
    );

    -- Register A: stores operand A for ALU
    mapReg_A: GenericRegister generic map(Dwidth) port map(
        clk => clk_i,
        en => Ain_i,
        rst => RF_rst_i,
        d => bus_r,
        q => reg_a_q
    );

    -- D-FF to store memory write address
    mapMemIn_DFF: GenericRegister generic map(Dwidth) port map(
        clk => clk_i,
        en => Mem_in_i,
        rst => RF_rst_i,
        d => bus_r,
        q => reg_dff_out_q
    );

    -- Tri-state drivers to share internal bus
    tristate_imm1: BidirPin generic map(Dwidth) port map(imm1_ext_r, bus_r, Imm1_in_i);
    tristate_imm2: BidirPin generic map(Dwidth) port map(imm2_ext_r, bus_r, Imm2_in_i);
    tristate_RF_data: BidirPin generic map(Dwidth) port map(rf_data_r, bus_r, RF_out_i);
    tristate_data_out: BidirPin generic map(Dwidth) port map(mem_out_r, bus_r, data_mem_out_i);

    -- Expose data memory output to testbench
    data_rd_data_o <= mem_out_r;

    -- MUX logic to select between TB and CPU-controlled memory signals
    mem_wr_en_mux_r      <= data_MemEn_i when tb_active_i = '0' else data_wr_en_i;
    mem_wr_data_mux_r    <= bus_r         when tb_active_i = '0' else data_wr_data_i;
    mem_wr_addr_mux_r    <= reg_dff_out_q(Awidth-1 downto 0) when tb_active_i = '0' else data_wr_addr_i;
    mem_rd_addr_mux_r    <= bus_r(Awidth-1 downto 0) when tb_active_i = '0' else data_rd_addr_i;

end DataArch;
