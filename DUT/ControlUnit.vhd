library ieee;

use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;

use ieee.std_logic_unsigned.all;

use work.aux_package.all;

--------------------------------------------------------------
-- ControlUnit: Top-level controller for multi-cycle CPU
-- Connects FSM (StateLogic) and microcontrol generator (ControlLines)
--------------------------------------------------------------

entity ControlUnit is
    generic(StateLength : integer := 5);  -- Length of state vector (e.g., 5 bits for 32 states)
    port(
        -- Clock, Reset, Enable
        clk         : in std_logic;
        rst         : in std_logic;
        ena         : in std_logic;

        -- ALU status flags
        ALU_c       : in std_logic;  -- Carry
        ALU_z       : in std_logic;  -- Zero
        ALU_n       : in std_logic;  -- Negative

        done        : out std_logic;

        -- Instruction opcode (from IR)
        opcode    : in std_logic_vector(3 downto 0);

        RF_addr_rd  : out std_logic_vector(1 downto 0);
        RF_addr_wr  : out std_logic_vector(1 downto 0);

        -- Datapath control signals
        DTCM_wr         : out std_logic;
        DTCM_addr_sel   : out std_logic;
        DTCM_addr_out   : out std_logic;
        DTCM_addr_in    : out std_logic;
        DTCM_out        : out std_logic;
        ALU_op          : out std_logic_vector(2 downto 0); -- !!! needs to be change to ALUFN_o
        Ain             : out std_logic;
        RF_WregEn       : out std_logic;
        RF_out          : out std_logic;

        IRin            : out std_logic;
        PCin            : out std_logic;
        PCsel           : out std_logic_vector(1 downto 0);
        Imm1_in         : out std_logic;
        Imm2_in         : out std_logic;

        -- Debug/Status output: concatenated flags and opcode status
        status_bits     : out std_logic_vector(14 downto 0)
    );
end ControlUnit;

--------------------------------------------------------------
-- Architecture: Connects StateLogic and ControlLines modules
--------------------------------------------------------------

architecture ControlArch of ControlUnit is
	signal state_r		: std_logic_vector(StateLength-1 downto 0);
begin

    ----------------------------------------------------------
    -- FSM Instance: Generates current control state
    ----------------------------------------------------------
    StateLogic_inst: StateLogic
        generic map(StateLength)
        port map (
            clk             => clk,
            ena             => ena,
            rst             => rst,
            ALU_cflag       => ALU_c,
            opcode	        => opcode,
            current_state   => state_r
        );

    ----------------------------------------------------------
    -- Microcontroller Instance: Generates control signals
    -- based on current FSM state, opcode, and ALU flags
    ----------------------------------------------------------
    ControlLines_inst: ControlLines
        generic map(StateLength)
        port map (
            clk             => clk,
            rst             => rst,
            ena             => ena,
            state           => state_r,
            opcode        	=> opcode,
            ALU_c           => ALU_c,
            ALU_z           => ALU_z,
            ALU_n           => ALU_n,
            done            => done,

            -- Outputs to datapath
            DTCM_wr         => DTCM_wr,
            DTCM_addr_sel   => DTCM_addr_sel,
            DTCM_addr_out   => DTCM_addr_out,
            DTCM_addr_in    => DTCM_addr_in,
            DTCM_out        => DTCM_out,
            ALU_op          => ALU_op,
            Ain             => Ain,
            RF_WregEn       => RF_WregEn,
            RF_out          => RF_out,
            RF_addr_rd      => RF_addr_rd,
            RF_addr_wr      => RF_addr_wr,
            IRin            => IRin,
            PCin            => PCin,
            PCsel           => PCsel,
            Imm1_in         => Imm1_in,
            Imm2_in         => Imm2_in,

            -- Flags to status register
            status_bits     => status_bits(14 downto 0)
        );

end ControlArch;
