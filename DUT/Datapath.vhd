library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;

--------------------------------------------------------------
-- Datapath: Refactored with consistent signal naming
--------------------------------------------------------------

entity Datapath is
    generic(
        Dwidth : integer := 16;
        Awidth : integer := 6;
        dept   : integer := 64
    );
    port(
        clk_i               : in std_logic;
        data_in_i           : in std_logic_vector(Dwidth-1 downto 0);
        prog_wr_addr_i      : in std_logic_vector(Awidth-1 downto 0);
        prog_wr_en_i        : in std_logic;
        tb_active_i         : in std_logic;
        data_wr_addr_i      : in std_logic_vector(Awidth-1 downto 0);
        data_wr_data_i      : in std_logic_vector(Dwidth-1 downto 0);
        data_wr_en_i        : in std_logic;
        data_rd_data_o      : out std_logic_vector(Dwidth-1 downto 0);
        data_rd_addr_i      : in std_logic_vector(Awidth-1 downto 0);

        alu_c_o             : out std_logic;
        alu_z_o             : out std_logic;
        alu_n_o             : out std_logic;
        opcode_o            : out std_logic_vector(3 downto 0);

        RF_out_i            : in std_logic;
        data_mem_out_i      : in std_logic;
        Cout_i              : in std_logic;
        Imm2_in_i           : in std_logic;
        Imm1_in_i           : in std_logic;
        IRin_i              : in std_logic;
        RF_addr_i           : in std_logic_vector(1 downto 0);
        PCsel_i             : in std_logic_vector(1 downto 0);
        RF_WregEn_i         : in std_logic;
        RF_rst_i            : in std_logic;
        Ain_i               : in std_logic;
        Cin_i               : in std_logic;
        Mem_in_i            : in std_logic;
        data_MemEn_i        : in std_logic;
        PCin_i              : in std_logic;
        ALU_op_i            : in std_logic_vector(2 downto 0)
    );
end Datapath;

architecture DataArch of Datapath is

    signal rf_addr_mux_r              : std_logic_vector(3 downto 0);
    signal imm1_ext_r, imm2_ext_r     : std_logic_vector(Dwidth-1 downto 0);
    signal imm_pc_r                   : std_logic_vector(7 downto 0);
    signal pc_addr_r                  : std_logic_vector(Awidth-1 downto 0);
    signal instr_r                    : std_logic_vector(Dwidth-1 downto 0);
	signal bus_a_r                    : std_logic_vector(Dwidth-1 downto 0);
	signal bus_b_r                    : std_logic_vector(Dwidth-1 downto 0);
    signal rf_data_r                  : std_logic_vector(Dwidth-1 downto 0);
    signal reg_a_q                    : std_logic_vector(Dwidth-1 downto 0);
    signal alu_result_r               : std_logic_vector(Dwidth-1 downto 0);
    signal data_wr_en_mux_r           : std_logic;
    signal data_wr_data_mux_r         : std_logic_vector(Dwidth-1 downto 0);
    signal data_wr_addr_mux_r         : std_logic_vector(Awidth-1 downto 0);
    signal data_rd_addr_mux_r         : std_logic_vector(Awidth-1 downto 0);
    signal data_mem_out_r             : std_logic_vector(Dwidth-1 downto 0);
    signal mem_addr_dff_q             : std_logic_vector(Dwidth-1 downto 0);

begin

    -- IR
    mapIR: IR generic map(Dwidth) port map (
        clk_i         => clk_i,
        ena_i         => IRin_i,
        rst_i         => RF_rst_i,
        RFaddr_rd_i   => RF_addr_i,
        RFaddr_wr_i   => RF_addr_i,
        IR_content_i  => instr_r,
        opcode_o      => opcode_o,
        addr_o        => rf_addr_mux_r,
        signext1_o    => imm1_ext_r,
        signext2_o    => imm2_ext_r,
        imm_to_PC_o   => imm_pc_r
    );

    -- Program Memory
    mapProgMem: ProgMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk_i, memEn => prog_wr_en_i, WmemData => data_in_i,
        WmemAddr => prog_wr_addr_i, RmemAddr => pc_addr_r,
        RmemData => instr_r
    );

    -- PC Logic
    mapPC: PCLogic generic map(Awidth) port map(
        clk => clk_i, i_PCin => PCin_i, i_PCsel => PCsel_i,
        i_IR_imm => imm_pc_r,
        o_currentPC => pc_addr_r
    );

    -- Register File
    mapRegisterFile: RF port map(
        clk => clk_i, rst => RF_rst_i, WregEn => RF_WregEn_i,
        WregData => bus_a_r, RregAddr => rf_addr_mux_r, WregAddr => rf_addr_mux_r,
        RregData => rf_data_r
    );

    -- ALU
    mapALU: ALU_main generic map(Dwidth) port map(
        reg_a_out => reg_a_q,
        reg_b_in => bus_b_r,
        ALU_op => ALU_op_i,
        result => alu_result_r,
        C => alu_c_o, N => alu_n_o, Z => alu_z_o
    );

    -- Register C
    mapReg_C: GenericRegister generic map(Dwidth) port map(
    clk_i   => clk_i,
    ena_i   => Cin_i,
    rst_i   => RF_rst_i,
    d_i     => alu_result_r,
    q_o     => bus_a_r
);

    -- Data Memory
    mapDataMem: dataMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk_i, memEn => data_wr_en_mux_r, WmemData => data_wr_data_mux_r,
        WmemAddr => data_wr_addr_mux_r, RmemAddr => data_rd_addr_mux_r,
        RmemData => data_mem_out_r
    );

    -- Register A
    mapReg_A: GenericRegister generic map(Dwidth) port map(
    clk_i   => clk_i,
    ena_i   => Ain_i,
    rst_i   => RF_rst_i,
    d_i     => bus_a_r,
    q_o     => reg_a_q
);

    -- DFF for memory address
    mapMemIn_D_FF: GenericRegister generic map(Dwidth) port map(
    clk_i   => clk_i,
    ena_i   => Mem_in_i,
    rst_i   => RF_rst_i,
    d_i     => bus_b_r,
    q_o     => mem_addr_dff_q
);

    -- Tri-state drivers for shared bus
    tristate_imm1: BidirPin generic map(Dwidth) port map(imm1_ext_r, bus_b_r, Imm1_in_i);
    tristate_imm2: BidirPin generic map(Dwidth) port map(imm2_ext_r, bus_b_r, Imm2_in_i);
    tristate_RF_data: BidirPin generic map(Dwidth) port map(rf_data_r, bus_b_r, RF_out_i);
    tristate_data_out: BidirPin generic map(Dwidth) port map(data_mem_out_r, bus_b_r, data_mem_out_i);

    -- Output to TB
    data_rd_data_o <= data_mem_out_r;

    -- MUX logic for TB vs CPU memory control
    data_wr_en_mux_r      <= data_MemEn_i when tb_active_i = '0' else data_wr_en_i;
    data_wr_data_mux_r    <= bus_b_r       when tb_active_i = '0' else data_wr_data_i;
    data_wr_addr_mux_r    <= mem_addr_dff_q(Awidth-1 downto 0) when tb_active_i = '0' else data_wr_addr_i;
    data_rd_addr_mux_r    <= bus_b_r(Awidth-1 downto 0) when tb_active_i = '0' else data_rd_addr_i;

end DataArch;
