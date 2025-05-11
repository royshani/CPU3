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
        RF_out_o      : out std_logic;
        Data_mem_out_o: out std_logic;
        Cout_o        : out std_logic;
        Imm2_in_o     : out std_logic;
        Imm1_in_o     : out std_logic;
        IRin_o        : out std_logic;

        RF_addr_o     : out std_logic_vector(1 downto 0);
        PCsel_o       : out std_logic_vector(1 downto 0);

        RF_WregEn_o   : out std_logic;
        RF_rst_o      : out std_logic;
        Ain_o         : out std_logic;
        Cin_o         : out std_logic;
        Mem_in_o      : out std_logic;
        Data_MemEn_o  : out std_logic;
        Pcin_o        : out std_logic;

        ALU_op_o      : out std_logic_vector(2 downto 0);  -- ALU operation code

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
            RF_out_o        => RF_out_o,
            Data_mem_out_o  => Data_mem_out_o,
            Cout_o          => Cout_o,
            Imm2_in_o       => Imm2_in_o,
            Imm1_in_o       => Imm1_in_o,
            IRin_o          => IRin_o,
            RF_addr_o       => RF_addr_o,
            PCsel_o         => PCsel_o,
            RF_WregEn_o     => RF_WregEn_o,
            RF_rst_o        => RF_rst_o,
            Ain_o           => Ain_o,
            Cin_o           => Cin_o,
            Mem_in_o        => Mem_in_o,
            Data_MemEn_o    => Data_MemEn_o,
            Pcin_o          => Pcin_o,
            ALU_op_o        => ALU_op_o,

            -- Flags to status register
            cflag_o         => status_bits_o(12),
            zflag_o         => status_bits_o(11),
            nflag_o         => status_bits_o(10),
            status_bits_o   => status_bits_o(9 downto 0)
        );

end ControlArch;
