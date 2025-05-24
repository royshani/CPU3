library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;

--------------------------------------------------------------
-- Datapath: Refactored with consistent signal naming (no Reg C)
--------------------------------------------------------------

entity Datapath is
    generic(
        Dwidth : integer := 16;
        Awidth : integer := 6;
        dept   : integer := 64
    );
    port(
        clk               : in std_logic;
		ena				: in std_logic;
		rst				: in std_logic;

		
        alu_c             : out std_logic;
        alu_z             : out std_logic;
        alu_n             : out std_logic;
        opcode            : out std_logic_vector(3 downto 0);

		-- control signals
        DTCM_wr       : in std_logic;
        DTCM_addr_sel : in std_logic;		
        DTCM_addr_out : in std_logic;	
        DTCM_addr_in  : in std_logic;		
        DTCM_out      : in std_logic;
        ALU_op         : in std_logic_vector(2 downto 0); 
        Ain           : in std_logic;
        RF_WregEn     : in std_logic;
        RF_out        : in std_logic;
        RF_addr_rd    : in std_logic_vector(1 downto 0);
        RF_addr_wr    : in std_logic_vector(1 downto 0);	
--		addr_rd, addr_wr   : in std_logic_vector(3 downto 0);
        IRin          : in std_logic;
        PCin          : in std_logic;
        PCsel         : in std_logic_vector(1 downto 0);
        Imm1_in       : in std_logic;
        Imm2_in       : in std_logic;

		-- TB inputs
		DTCM_tb_out    	    : out std_logic_vector(Dwidth-1 downto 0);
		tb_active         : in std_logic;
		DTCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
		DTCM_tb_addr_out  : in std_logic_vector(Awidth-1 downto 0);
		DTCM_tb_wr        : in std_logic;
        DTCM_tb_in      	: in std_logic_vector(Dwidth-1 downto 0);
		ITCM_tb_in        : in std_logic_vector(Dwidth-1 downto 0);
        ITCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
        ITCM_tb_wr        : in std_logic

    );
end Datapath;

architecture DataArc of Datapath is

    signal addr_rd              : std_logic_vector(3 downto 0);
	signal addr_wr              : std_logic_vector(3 downto 0);
    signal imm1_ext_r, imm2_ext_r     : std_logic_vector(Dwidth-1 downto 0);
    signal imm_pc_r                   : std_logic_vector(7 downto 0);
    signal pc_addr_r                  : std_logic_vector(Awidth-1 downto 0);
    signal instr_r                    : std_logic_vector(Dwidth-1 downto 0);
    signal bus_a_r                    : std_logic_vector(Dwidth-1 downto 0);
    signal bus_b_r                    : std_logic_vector(Dwidth-1 downto 0);
    signal rf_data_r                  : std_logic_vector(Dwidth-1 downto 0);
    signal reg_a_q                    : std_logic_vector(Dwidth-1 downto 0);
    signal data_wr_en_mux_r           : std_logic;
    signal data_wr_data_mux_r         : std_logic_vector(Dwidth-1 downto 0);
    signal data_wr_addr_mux_r         : std_logic_vector(Awidth-1 downto 0);
	signal data_addr_out_mux_r 		  : std_logic_vector(Awidth-1 downto 0);
	signal data_addr_in_mux_r  		  : std_logic_vector(Awidth-1 downto 0);
    signal data_rd_addr_mux_r         : std_logic_vector(Awidth-1 downto 0);
	signal data_wr_addr_mux_q         : std_logic_vector(Awidth-1 downto 0);
	signal data_rd_addr_mux_q         : std_logic_vector(Awidth-1 downto 0);
    signal data_mem_out_r             : std_logic_vector(Dwidth-1 downto 0);
    signal mem_addr_dff_q             : std_logic_vector(Dwidth-1 downto 0);

begin

    -- IR
    mapIR: IR generic map(Dwidth) port map (
        clk         => clk,
        ena        => IRin,
        rst         => rst,
        RF_addr_rd   => RF_addr_rd,
        RF_addr_wr   => RF_addr_wr,
        IR_content  => instr_r,
        opcode      => opcode,
		addr_rd	  => addr_rd,
		addr_wr	  => addr_wr,
        signext1    => imm1_ext_r,
        signext2    => imm2_ext_r,
        imm_to_PC   => imm_pc_r
    );

    -- Program Memory
    mapProgMem: ProgMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk, memEn => ITCM_tb_wr, WmemData => ITCM_tb_in,
        WmemAddr => ITCM_tb_addr_in, RmemAddr => pc_addr_r,
        RmemData => instr_r
    );

    -- PC Logic
    mapPC: PCLogic generic map(Awidth) port map(
        clk => clk, i_PCin => PCin, i_PCsel => PCsel,
        IR_imm => imm_pc_r,
        currentPC => pc_addr_r
    );

    -- Register File
    mapRegisterFile: RF port map(
        clk => clk, rst => rst, WregEn => RF_WregEn,
        WregData => bus_a_r, RregAddr => addr_rd, WregAddr => addr_wr,
        RregData => rf_data_r
    );

    -- ALU (writes directly to bus A)
    mapALU: ALU_main generic map(Dwidth) port map(
        reg_a_q   => reg_a_q,
        reg_b_r   => bus_b_r,
        i_ctrl    	=> ALU_op,
		Ain		=> Ain,
        result    => bus_a_r,
        cflag     => alu_c,
        nflag     => alu_n,
        zflag     => alu_z
    );

    -- Register A
    mapReg_A: GenericRegister generic map(Dwidth) port map(
        clk   => clk,
        ena   => Ain,
        rst   => rst,
        d     => bus_a_r,
        q     => reg_a_q
    );

    -- Data Memory
    mapDataMem: dataMem generic map(Dwidth, Awidth, dept) port map(
        clk => clk, memEn => data_wr_en_mux_r, WmemData => data_wr_data_mux_r,
        WmemAddr => data_wr_addr_mux_r, RmemAddr => data_rd_addr_mux_r,
        RmemData => data_mem_out_r
    );

    -- DFF for memory address read
    mapMemIn_D_FF_rd: GenericRegister generic map(Awidth) port map(
        clk   => clk,
        ena   => DTCM_addr_out,
        rst   => rst,
        d     => data_addr_out_mux_r,
        q     => data_rd_addr_mux_q
    );
	-- DFF for memory address write
    mapMemIn_D_FF_wr: GenericRegister generic map(Awidth) port map(
        clk   => clk,
        ena   => DTCM_addr_in,
        rst   => rst,
        d     => data_addr_in_mux_r,
        q     => data_wr_addr_mux_q
    );

	-- Imm1
	tristate_imm1: BidirPin generic map(Dwidth) port map(
		i_data  => imm1_ext_r,
		enable_out    => Imm1_in,
		o_data => bus_b_r
	);

	-- Imm2
	tristate_imm2: BidirPin generic map(Dwidth) port map(
		i_data  => imm2_ext_r,
		enable_out    => Imm2_in,
		o_data => bus_b_r
	);

	-- Register File output
	tristate_RF_data: BidirPin generic map(Dwidth) port map(
		i_data  => rf_data_r,
		enable_out    => RF_out,
		o_data => bus_b_r
	);

	-- Data memory output
	tristate_data_out: BidirPin generic map(Dwidth) port map(
		i_data  => data_mem_out_r,
		enable_out    => DTCM_out,
		o_data => bus_b_r
	);
    -- Output to TB
    DTCM_tb_out <= data_mem_out_r;

    -- MUX logic for TB vs CPU memory control
    data_wr_en_mux_r      <= DTCM_wr when tb_active = '0' else DTCM_tb_wr;
    data_wr_data_mux_r    <= bus_b_r       when tb_active = '0' else DTCM_tb_in;
    data_wr_addr_mux_r    <= data_wr_addr_mux_q(Awidth-1 downto 0) when tb_active = '0' else DTCM_tb_addr_in;
    data_rd_addr_mux_r    <= data_rd_addr_mux_q(Awidth-1 downto 0) when tb_active = '0' else DTCM_tb_addr_out;
	data_addr_out_mux_r	  <= bus_a_r(Awidth-1 downto 0)	when DTCM_addr_sel = '0' else bus_b_r(Awidth-1 downto 0);
	data_addr_in_mux_r	  <= bus_a_r(Awidth-1 downto 0)	when DTCM_addr_sel = '0' else bus_b_r(Awidth-1 downto 0);
	

end DataArc;