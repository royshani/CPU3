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
    clk              : in std_logic;  -- Clock signal fed from TB
    rst              : in std_logic;  -- Reset signal fed from TB
    ena              : in std_logic;  -- Enable signal for control unit fed from TB
    done             : out std_logic; -- Done flag to TB
    

        -- TB inputs
    DTCM_tb_out    	    : out std_logic_vector(Dwidth-1 downto 0);
    tb_active         : in std_logic:= '0';
    DTCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
    DTCM_tb_wr        : in std_logic;
    DTCM_tb_addr_out  : in std_logic_vector(Awidth-1 downto 0);
    DTCM_tb_in      	: in std_logic_vector(Dwidth-1 downto 0);
    ITCM_tb_in        : in std_logic_vector(Dwidth-1 downto 0);
    ITCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
    ITCM_tb_wr        : in std_logic
);
END top;

ARCHITECTURE topArch OF top IS 

    -- Signals from Datapath to Control (flags and opcode)
    signal alu_c, alu_z, alu_n : std_logic;                    -- ALU flags: carry, zero, negative
    signal opcode              : std_logic_vector(3 downto 0); -- Opcode extracted from instruction

    -- Control signals sent to Datapath

     signal DTCM_addr_sel  : std_logic;
     signal DTCM_addr_out  : std_logic;
     signal DTCM_addr_in   : std_logic;
     signal DTCM_out       : std_logic;
     signal DTCM_wr 		  : std_logic;
     signal ALU_op          : std_logic_vector(2 downto 0);
     signal Ain             : std_logic;
     signal RF_WregEn       : std_logic;
     signal RF_out          : std_logic;
     signal RF_addr_rd      : std_logic_vector(1 downto 0);
     signal RF_addr_wr      : std_logic_vector(1 downto 0);
     signal IRin            : std_logic;
     signal PCin            : std_logic;
     signal PCsel           : std_logic_vector(1 downto 0);
     signal Imm1_in         : std_logic;
     signal Imm2_in         : std_logic;
     signal status_bits     : std_logic_vector(14 downto 0);
     signal done_r          : std_logic;

BEGIN

    -- Datapath Instantiation
    mapDatapath: Datapath generic map(Dwidth, Awidth, dept) port map(
        clk              => clk,
        ena              => ena,
        rst              => rst,

        alu_c            => alu_c,
        alu_z            => alu_z,
        alu_n            => alu_n,
        opcode         => opcode,
        

        
        DTCM_wr          => DTCM_wr,
        DTCM_addr_sel    => DTCM_addr_sel,
        DTCM_addr_out    => DTCM_addr_out,
        DTCM_addr_in     => DTCM_addr_in,
        DTCM_out         => DTCM_out,
        ALU_op           => ALU_op,
        Ain              => Ain,
        RF_WregEn        => RF_WregEn,
        RF_out           => RF_out,
        RF_addr_rd       => RF_addr_rd,
        RF_addr_wr       => RF_addr_wr,
        IRin             => IRin,
        PCin             => PCin,
        PCsel            => PCsel,
        Imm1_in          => Imm1_in,
        Imm2_in          => Imm2_in,

        DTCM_tb_out      => DTCM_tb_out,
        tb_active        => tb_active,
        DTCM_tb_addr_in  => DTCM_tb_addr_in,
        DTCM_tb_addr_out => DTCM_tb_addr_out,
        DTCM_tb_wr       => DTCM_tb_wr,
        DTCM_tb_in       => DTCM_tb_in,
        ITCM_tb_in       => ITCM_tb_in,
        ITCM_tb_addr_in  => ITCM_tb_addr_in,
        ITCM_tb_wr       => ITCM_tb_wr
    );


    -- Control Unit Instantiation
    mapControl: ControlUnit generic map(StateLength) port map(
        clk              => clk,
        rst              => rst,
        ena              => ena,

        ALU_c            => alu_c,
        ALU_z            => alu_z,
        ALU_n            => alu_n,
        opcode         => opcode,
        done             => done_r,
        DTCM_wr          => DTCM_wr,
        DTCM_addr_sel    => DTCM_addr_sel,
        DTCM_addr_out    => DTCM_addr_out,
        DTCM_addr_in     => DTCM_addr_in,
        DTCM_out         => DTCM_out,
        ALU_op           => ALU_op,
        Ain              => Ain,
        RF_WregEn        => RF_WregEn,
        RF_out           => RF_out,
        RF_addr_rd       => RF_addr_rd,
        RF_addr_wr       => RF_addr_wr,
        IRin             => IRin,
        PCin             => PCin,
        PCsel            => PCsel,
        Imm1_in          => Imm1_in,
        Imm2_in          => Imm2_in,


        status_bits      => status_bits
        
    );

    done <= done_r;
END topArch;
