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
        clk_i         : in std_logic;
        rst_i         : in std_logic;
        ena_i         : in std_logic;

        -- ALU status flags
        ALU_c_i       : in std_logic;  -- Carry
        ALU_z_i       : in std_logic;  -- Zero
        ALU_n_i       : in std_logic;  -- Negative

        -- Instruction opcode (from IR)
        opcode_i      : in std_logic_vector(3 downto 0);

        -- Datapath control signals
        DTCM_wr_o       : out std_logic;
		DTCM_addr_sel_o : out std_logic;		
		DTCM_addr_out_o : out std_logic;	
        DTCM_addr_in_o  : out std_logic;		
        DTCM_out_o      : out std_logic;
        ALUFN_o         : out std_logic_vector(2 downto 0); -- !!! needs to be change to ALUFN_o
        Ain_o           : out std_logic;
        RF_WregEn_o     : out std_logic;
        RF_out_o        : out std_logic;
		
		
		RF_addr_rd_o    : out std_logic_vector(1 downto 0);
        RF_addr_wr_o    : out std_logic_vector(1 downto 0);		
		IRin_o          : out std_logic;
		PCin_o          : out std_logic;
        PCsel_o         : out std_logic_vector(1 downto 0);
        Imm1_in_o       : out std_logic;
		Imm2_in_o       : out std_logic;

        -- Debug/Status output: concatenated flags and opcode status
        status_bits_o : out std_logic_vector(12 downto 0)
    );
end ControlUnit;

--------------------------------------------------------------
-- Architecture: Connects StateLogic and ControlLines modules
--------------------------------------------------------------

architecture ControlArch of ControlUnit is
    -- Internal signal for current FSM state
    signal state_r : std_logic_vector(StateLength-1 downto 0);
begin

    ----------------------------------------------------------
    -- FSM Instance: Generates current control state
    ----------------------------------------------------------
    StateLogic_inst: StateLogic
        generic map(StateLength)
        port map (
            clk_i           => clk_i,
            ena_i           => ena_i,
            rst_i           => rst_i,
            ALU_cflag_i     => ALU_c_i,
            opcode_i        => opcode_i,
            current_state_o => state_r
        );

    ----------------------------------------------------------
    -- Microcontroller Instance: Generates control signals
    -- based on current FSM state, opcode, and ALU flags
    ----------------------------------------------------------
    ControlLines_inst: ControlLines
        generic map(StateLength)
        port map (
            clk_i           => clk_i,
            rst_i           => rst_i,
            state_i         => state_r,
            opcode_i        => opcode_i,
            ALU_c_i         => ALU_c_i,
            ALU_z_i         => ALU_z_i,
            ALU_n_i         => ALU_n_i,

            -- Outputs to datapath
            DTCM_wr_o         => DTCM_wr_o,
            DTCM_addr_sel_o   => DTCM_addr_sel_o,
            DTCM_addr_out_o   => DTCM_addr_out_o,
            DTCM_addr_in_o    => DTCM_addr_in_o,
            DTCM_out_o        => DTCM_out_o,
            ALUFN_o           => ALUFN_o,
            Ain_o             => Ain_o,
            RF_WregEn_o       => RF_WregEn_o,
            RF_out_o          => RF_out_o,
            RF_addr_rd_o      => RF_addr_rd_o,
            RF_addr_wr_o      => RF_addr_wr_o,
            IRin_o            => IRin_o,
            PCin_o            => PCin_o,
            PCsel_o           => PCsel_o,
            Imm1_in_o         => Imm1_in_o,
            Imm2_in_o         => Imm2_in_o,

            -- Flags to status register
            cflag_o         => status_bits_o(12),
            zflag_o         => status_bits_o(11),
            nflag_o         => status_bits_o(10),
            status_bits_o   => status_bits_o(9 downto 0)
        );

end ControlArch;
