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
		ena_i		 : in std_logic;
        state_i      : in std_logic_vector(StateLength-1 downto 0);
        opcode_i     : in std_logic_vector(3 downto 0);
        ALU_c_i      : in std_logic;
        ALU_z_i      : in std_logic;
        ALU_n_i      : in std_logic;

        -- Datapath control signal outputs

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


        -- Output flags and status encoding
        cflag_o         : out std_logic;
        zflag_o         : out std_logic;
        nflag_o         : out std_logic;
        status_bits_o   : out std_logic_vector(14 downto 0)
		done			: out std_logic;
    );
end ControlLines;

--------------------------------------------------------------
-- Architecture: Decodes state and opcode into control lines
--------------------------------------------------------------

architecture ctrlArch of ControlLines is

    -- Control mux: 5 control signals grouped (bus control)
    signal bus_ctrl_r    : std_logic_vector(3 downto 0); -- (RF_out, Data_mem_out, Imm2_in, Imm1_in)
    signal flags_q       : std_logic_vector(2 downto 0); -- Stored flags (C, Z, N)
    signal concat_op_r   : std_logic_vector(4 downto 0); -- (opcode & cflag) for jump decision logic

begin

    -- Assign bus control signals
    RF_out_o        <= bus_ctrl_r(3); -- changed from 4 to 3
    DTCM_out_o		<= bus_ctrl_r(2); -- changed from 3 to 2
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
        bus_ctrl_r      <=  (others => '0');
        IRin_o          <=  '0';
        RF_WregEn_o     <=  '0';
        Ain_o           <=  '0';
        DTCM_addr_in_o  <=  '0';
		DTCM_addr_out_o <=  '0';
		DTCM_addr_sel_o <=  '0';
        DTCM_wr_o       <=  '0';
        PCin_o          <=  '0';
        ALUFN_o         <=  "111";
		RF_addr_rd_o    <=  "00";
        RF_addr_wr_o    <=  "00";
		done		 	<=  '0';

        case state_v is
            when 0 =>  -- reset
                PCin_o      <= '1';
				PCsel_o         <=  "00"; -- default values


            when 1 =>  -- FETCH
                IRin_o      <= '1';
                PCin_o      <= '1';
				PCsel_o		<= "10";


            when 2 =>  -- Register Fetch (RT)
                bus_ctrl_r   <= "1000"; -- RF_out enabled
                RF_addr_rd_o <= "10";  -- read rb
                Ain_o        <= '1';  -- load rb to reg A by ALU

            when 3 =>  -- Jump unconditional
                PCin_o      <= '1';
                PCsel_o     <= "01";

            when 4 =>  -- Jump conditional (JC, JNC)
                case concat_op_r is
                    when "10001" =>  -- JC: Carry=1
                        PCsel_o <= "01"; PCin_o <= '1';
                    when "10010" =>  -- JNC: Carry=0
                        PCsel_o <= "01"; PCin_o <= '1';
                    when others =>
                        PCsel_o <= "10"; PCin_o <= '0';
                end case;

            when 5 =>  -- MOVE
                bus_ctrl_r    <= "0001"; -- Imm1_in
                Ain_o         <= '1';  -- load rb to reg A by ALU
                RF_addr_wr_o  <= "01"; -- write to ra
                RF_WregEn_o   <= '1';

            when 6 =>  -- st/ld setup
                bus_ctrl_r    <= "0010"; -- Imm2_in
                Ain_o         <= '1';

            when 7 =>  -- DONE (NOP)
                -- all control lines off
                PCsel_o <= "00";
				done 	<= '1';

            when 8 to 12 =>  -- ALU operations: ADD/SUB/AND/OR/XOR
                bus_ctrl_r    <= "1000"; -- RF_out enable
                RF_addr_rd_o  <= "11"; -- load rc register to entrance B of ALU

                case state_v is
                    when 8  => ALUFN_o <= "000";  -- ADD
                    when 9  => ALUFN_o <= "001";  -- SUB
                    when 10 => ALUFN_o <= "010";  -- AND
                    when 11 => ALUFN_o <= "011";  -- OR
                    when 12 => ALUFN_o <= "100";  -- XOR
                    when others => null;
                end case;

            when 13 =>  -- RT writeback
                RF_addr_wr_o  <= "01";
                RF_WregEn_o   <= '1';

            when 14 =>  -- st/ld decide
				bus_ctrl_r    <= "1000";  -- RF_out
				RF_addr_rd_o  <= "10"; -- sum rb with REG A
				-- Ain_o         <= '1';  -- load rb to reg A by ALU
				ALUFN_o       <= "000"; -- for rb load

            when 15 =>  -- ST phase 1 (need to make sure bus_a to readAddr
				RF_addr_rd_o		<= "01";
				bus_ctrl_r			<= "1000";
				

            when 16 =>  -- ST → memory write
                DTCM_wr_o 	  		<= '1'; -- allows us  to load into data memory
                DTCM_addr_in_o      <= '1'; -- allows the address of the store to be used in mux (need to create mux)
				
            when 17 =>  -- LD phase 1 

				DTCM_addr_out_o <= '1';
				

            when 18 =>  -- LD → register write 
                -- maybe add DTCM write
				bus_ctrl_r		<= "0100";
				Ain_o			<= '1';
				RF_WregEn_o		<= '1';
				RF_addr_wr_o	<= "01";
				

            when 19 =>  -- DEC (decode)
                -- Reset fetch lines (IRin, Pcin)
                IRin_o        <= '0';
                PCin_o        <= '0';
                PCsel_o       <= "10";

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
                when 8 | 9 => -- ADD or SUB
                    flags_q <= ALU_c_i & ALU_z_i & ALU_n_i;  -- C,Z,N
                when 10 | 11 | 12 => -- AND , OR or XOR
                    flags_q(1 downto 0) <= ALU_z_i & ALU_n_i;
                when others =>
                    null;
            end case;
        end if;
    end process;

	-- Status Bit Encoding: For external monitoring/debug
	-- Format: [MOV][DONE][AND][OR][XOR][JNC][JC][JMP][C][Z][N][LD][ST]
	-- Assign opcode-related bits (excluding bits 4:2)
	with opcode_i select
		status_bits_o(14 downto 5) <= "10000000" when "1100", -- mov
									  "01000000" when "1111", -- done
									  "00100000" when "0010", -- and
									  "00010000" when "0011", -- or
									  "00001000" when "0100", -- xor
									  "00000100" when "1001", -- jnc
									  "00000010" when "1000", -- jc
									  "00000001" when "0111", -- jmp
									  "00000000" when others;

	-- Assign fixed status bits
	status_bits_o(4) <= flags_q(2);  -- Carry flag
	status_bits_o(3) <= flags_q(1);  -- Zero flag
	status_bits_o(2) <= flags_q(0);  -- Negative flag
	status_bits_o(1) <= '1' when opcode_i = "1101" else '0'; -- Load
	status_bits_o(0) <= '1' when opcode_i = "1110" else '0'; -- Store

end ctrlArch;