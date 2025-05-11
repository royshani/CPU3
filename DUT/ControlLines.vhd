library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------
-- ControlLines: Micro-operation generator
-- Maps FSM state and opcode to datapath control signals
--------------------------------------------------------------

entity ControlLines is
    generic(StateLength : integer := 5);
    port(
        -- ControlUnit inputs
        clk_i        : in std_logic;
        rst_i        : in std_logic;
        state_i      : in std_logic_vector(StateLength-1 downto 0);
        opcode_i     : in std_logic_vector(3 downto 0);
        ALU_c_i      : in std_logic;
        ALU_z_i      : in std_logic;
        ALU_n_i      : in std_logic;

        -- Datapath control signal outputs
        RF_out_o        : out std_logic;
        Data_mem_out_o  : out std_logic;
        Cout_o          : out std_logic;
        Imm2_in_o       : out std_logic;
        Imm1_in_o       : out std_logic;
        IRin_o          : out std_logic;

        RF_addr_o       : out std_logic_vector(1 downto 0);
        PCsel_o         : out std_logic_vector(1 downto 0);
        RF_WregEn_o     : out std_logic;
        RF_rst_o        : out std_logic;
        Ain_o           : out std_logic;
        Cin_o           : out std_logic;
        Mem_in_o        : out std_logic;
        Data_MemEn_o    : out std_logic;
        Pcin_o          : out std_logic;
        ALU_op_o        : out std_logic_vector(2 downto 0);

        -- Output flags and status encoding
        cflag_o         : out std_logic;
        zflag_o         : out std_logic;
        nflag_o         : out std_logic;
        status_bits_o   : out std_logic_vector(9 downto 0)
    );
end ControlLines;

--------------------------------------------------------------
-- Architecture: Decodes state and opcode into control lines
--------------------------------------------------------------

architecture ctrlArch of ControlLines is

    -- Control mux: 5 control signals grouped (bus control)
    signal bus_ctrl_r    : std_logic_vector(4 downto 0); -- (RF_out, Data_mem_out, Cout, Imm2_in, Imm1_in)
    signal flags_q       : std_logic_vector(2 downto 0); -- Stored flags (C, Z, N)
    signal concat_op_r   : std_logic_vector(4 downto 0); -- (opcode & cflag) for jump decision logic

begin

    -- Assign bus control signals
    RF_out_o        <= bus_ctrl_r(4);
    Data_mem_out_o  <= bus_ctrl_r(3);
    Cout_o          <= bus_ctrl_r(2);
    Imm2_in_o       <= bus_ctrl_r(1);
    Imm1_in_o       <= bus_ctrl_r(0);

    -- Combine opcode and cflag for jump condition matching
    concat_op_r(4 downto 1) <= opcode_i;
    concat_op_r(0)          <= flags_q(2);  -- Carry flag (C)

    -- Drive output flag wires
    cflag_o <= flags_q(2);
    zflag_o <= flags_q(1);
    nflag_o <= flags_q(0);

    ----------------------------------------------------------
    -- Control logic: generates all datapath control lines
    -- based on FSM state and opcode
    ----------------------------------------------------------

    CtrlLogic: process(state_i, concat_op_r)
        variable state_v : integer range 0 to 31;
    begin
        state_v := conv_integer(state_i);

        -- Default values (optional: improve robustness)
        bus_ctrl_r     <= (others => '0');
        IRin_o         <= '0';
        RF_rst_o       <= '0';
        RF_WregEn_o    <= '0';
        Ain_o          <= '0';
        Cin_o          <= '0';
        Mem_in_o       <= '0';
        Data_MemEn_o   <= '0';
        Pcin_o         <= '0';
        PCsel_o        <= "00";
        ALU_op_o       <= "111";

        case state_v is
            when 0 =>  -- IDLE
                RF_rst_o    <= '1';
                Pcin_o      <= '1';

            when 1 =>  -- FETCH
                IRin_o      <= '1';
                RF_addr_o   <= "00";
                Pcin_o      <= '1';

            when 2 =>  -- Register Fetch (RT)
                bus_ctrl_r  <= "10000"; -- RF_out enabled
                RF_addr_o   <= "10";
                Ain_o       <= '1';

            when 3 =>  -- Jump unconditional
                Pcin_o      <= '1';
                PCsel_o     <= "01";

            when 4 =>  -- Jump conditional (JC, JNC)
                case concat_op_r is
                    when "10001" =>  -- JC: Carry=1
                        PCsel_o <= "01"; Pcin_o <= '1';
                    when "10000" =>  -- JNC: Carry=0
                        PCsel_o <= "10"; Pcin_o <= '0';
                    when "10010" =>  -- JMP (fallback)
                        PCsel_o <= "01"; Pcin_o <= '1';
                    when others =>
                        PCsel_o <= "10"; Pcin_o <= '0';
                end case;

            when 5 =>  -- MOVE
                bus_ctrl_r    <= "00001"; -- Imm1_in
                RF_addr_o     <= "01";
                RF_WregEn_o   <= '1';

            when 6 =>  -- ADDI setup
                bus_ctrl_r    <= "00010"; -- Imm2_in
                Ain_o         <= '1';

            when 7 =>  -- DONE (NOP)
                -- all control lines off
                PCsel_o <= "00";

            when 8 to 12 =>  -- ALU operations: ADD/SUB/AND/OR/XOR
                bus_ctrl_r    <= "10000";
                RF_addr_o     <= "11";
                Cin_o         <= '1';

                case state_v is
                    when 8  => ALU_op_o <= "000";  -- ADD
                    when 9  => ALU_op_o <= "001";  -- SUB
                    when 10 => ALU_op_o <= "010";  -- AND
                    when 11 => ALU_op_o <= "011";  -- OR
                    when 12 => ALU_op_o <= "100";  -- XOR
                    when others => null;
                end case;

            when 13 =>  -- RT writeback
                bus_ctrl_r    <= "00100";  -- Cout
                RF_addr_o     <= "01";
                RF_WregEn_o   <= '1';

            when 14 =>  -- ST phase 1
                bus_ctrl_r    <= "10000";  -- RF_out
                RF_addr_o     <= "10";
                Cin_o         <= '1';
                ALU_op_o      <= "000";

            when 15 =>  -- ST phase 2
                bus_ctrl_r    <= "00100";  -- Cout
                Mem_in_o      <= '1';

            when 16 =>  -- ST → memory write
                bus_ctrl_r    <= "10000";
                RF_addr_o     <= "01";
                Data_MemEn_o  <= '1';

            when 17 =>  -- LD phase 1
                bus_ctrl_r    <= "00100";
                Cin_o         <= '0';

            when 18 =>  -- LD → register write
                bus_ctrl_r    <= "01000"; -- Data_mem_out
                RF_addr_o     <= "01";
                RF_WregEn_o   <= '1';

            when 19 =>  -- DEC (decode)
                -- Reset fetch lines (IRin, Pcin)
                IRin_o        <= '0';
                Pcin_o        <= '0';
                PCsel_o       <= "00";

            when others =>
                -- Default no-op
                null;
        end case;
    end process;

    ----------------------------------------------------------
    -- Flag Register: Stores ALU flags for later decision use
    ----------------------------------------------------------
    FlagLogic: process(clk_i, rst_i)
        variable state_v : integer range 0 to 31;
    begin
        state_v := conv_integer(state_i);

        if rst_i = '1' then
            flags_q <= "000";
        elsif rising_edge(clk_i) then
            case state_v is
                when 8 | 9 =>
                    flags_q <= ALU_c_i & ALU_z_i & ALU_n_i;  -- C,Z,N
                when 10 | 11 | 12 =>
                    flags_q(1 downto 0) <= ALU_z_i & ALU_n_i;
                when others =>
                    null;
            end case;
        end if;
    end process;

    ----------------------------------------------------------
    -- Status Bit Encoding: For external monitoring/debug
    ----------------------------------------------------------
    with opcode_i select
        status_bits_o <= (9 => '1', others => '0') when "1100", -- mov
                         (8 => '1', others => '0') when "1111", -- done
                         (7 => '1', others => '0') when "0010", -- and
                         (6 => '1', others => '0') when "0011", -- or
                         (5 => '1', others => '0') when "0100", -- xor
                         (4 => '1', others => '0') when "1001", -- jnc
                         (3 => '1', others => '0') when "1000", -- jc
                         (2 => '1', others => '0') when "0111", -- jmp
                         (1 => '1', others => '0') when "0001", -- sub
                         (0 => '1', others => '0') when "0000", -- add
                         (others => '0') when others;

end ctrlArch;
