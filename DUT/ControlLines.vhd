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
        clk        : in std_logic;
        rst        : in std_logic;
		ena		 : in std_logic;
        state      : in std_logic_vector(StateLength-1 downto 0);
        opcode     : in std_logic_vector(3 downto 0);
        ALU_c      : in std_logic;
        ALU_z      : in std_logic;
        ALU_n      : in std_logic;

        -- Datapath control signal outputs

        DTCM_wr       : out std_logic;
		DTCM_addr_sel : out std_logic;		
		DTCM_addr_out : out std_logic;	
        DTCM_addr_in  : out std_logic;		
        DTCM_out      : out std_logic;
        ALU_op         : out std_logic_vector(2 downto 0); -- !!! needs to be change to ALU_op
        Ain           : out std_logic;
        RF_WregEn     : out std_logic;
        RF_out        : out std_logic;
		RF_addr_rd    : out std_logic_vector(1 downto 0);
        RF_addr_wr    : out std_logic_vector(1 downto 0);		
		IRin          : out std_logic;
		PCin          : out std_logic;
        PCsel         : out std_logic_vector(1 downto 0);
        Imm1_in       : out std_logic;
		Imm2_in       : out std_logic;


        -- Output flags and status encoding
        cflag         : out std_logic;
        zflag         : out std_logic;
        nflag         : out std_logic;
        status_bits   : out std_logic_vector(14 downto 0);
		done			: out std_logic := '0'
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
	signal done_r		 : std_logic :='0';
begin

    -- Assign bus control signals
    RF_out        <= bus_ctrl_r(3); -- changed from 4 to 3
    DTCM_out		<= bus_ctrl_r(2); -- changed from 3 to 2
    Imm2_in       <= bus_ctrl_r(1);
    Imm1_in       <= bus_ctrl_r(0);

    -- Combine opcode and cflag for jump condition matching
    concat_op_r(4 downto 1) <= opcode;
    concat_op_r(0)          <= flags_q(2);  -- Carry flag (C)

    -- Drive output flag wires
    cflag <= flags_q(2);
    zflag <= flags_q(1);
    nflag <= flags_q(0);

    ----------------------------------------------------------
    -- Control logic: generates all datapath control lines
    -- based on FSM state and opcode
    ----------------------------------------------------------

    
	CtrlLogic: process(state, concat_op_r)
        variable state_v : integer range 0 to 31;
		
    begin
        state_v := conv_integer(state);

        -- Default values (optional: improve robustness)
        bus_ctrl_r      <=  (others => '0');

        RF_WregEn     <=  '0';
        DTCM_addr_in  <=  '0';
		DTCM_addr_out <=  '0';
		DTCM_addr_sel <=  '0';
        DTCM_wr       <=  '0';
      --  ALU_op         <=  "111";
		--RF_addr_rd    <=  "00";
        --RF_addr_wr    <=  "00";


        case state_v is
            when 0 =>  -- reset
                PCin      <= '1';
				PCsel     <=  "00"; -- default values
				IRin          <=  '0';
				Ain        <= '0';
				report "reset state reached" severity note;


            when 1 =>  -- FETCH
                IRin      <= '1';
                PCin      <= '1';
				PCsel		<= "10"; -- PC + 1
				Ain        <= '0';
				report "fetch state reached" severity note;


            when 2 =>  -- R type (RT)
                bus_ctrl_r   <= "1000"; -- RF_out enabled
                RF_addr_rd <= "10";  -- read rb
                Ain        <= '1';  -- load rb to reg A by ALU
				PCin          <=  '0';
				IRin          <=  '0';
				ALU_op         <=  "111";
				report "RT state reached" severity note;

            when 3 =>  -- Jump unconditional
                PCin      <= '1';
                PCsel     <= "01";
				Ain        <= '0';
				
				report "JUMP state reached" severity note;

            when 4 =>  -- Jump conditional (JC, JNC)
				Ain        <= '0';
                case concat_op_r is
                    when "10001" =>  -- JC: Carry=1
                        PCsel <= "01"; PCin <= '1';
                    when "10010" =>  -- JNC: Carry=0
                        PCsel <= "01"; PCin <= '1';
                    when others =>
                        PCsel <= "10"; PCin <= '0';
                end case;
				report "JC state reached" severity note;

            when 5 =>  -- MOVE
                bus_ctrl_r  <= "0001"; -- Imm1_in
                Ain         <= '1';  -- load rb to reg A by ALU
                RF_addr_wr  <= "01"; -- write to ra
                RF_WregEn   <= '1';
				PCin        <=  '0';
				IRin		<= '0';
				ALU_op         <=  "111";
				report "MOVE state reached" severity note;

            when 6 =>  -- st/ld setup
                bus_ctrl_r    <= "0010"; -- Imm2_in
                Ain         <= '1';
				report "st/ld state reached" severity note;
				IRin          <=  '0';
				PCin          <=  '0';
				ALU_op         <=  "111";
				
            when 7 =>  -- DONE (NOP)
                -- all control lines off
                PCsel <= "00";
				done_r 	<= '1';
				Ain        <= '0';
				IRin          <=  '0';
				PCin          <=  '0';
				report "done state reached" severity note;

            when 8 to 12 =>  -- ALU operations: ADD/SUB/AND/OR/XOR
				bus_ctrl_r    <= "1000"; -- RF_out enable
                RF_addr_rd  <= "11"; -- load rc register to entrance B of ALU
				PCin          <=  '0';
				IRin          <=  '0';
				Ain        <= '0';
                case state_v is
                    when 8  => ALU_op <= "000";  -- ADD
                    when 9  => ALU_op <= "001";  -- SUB
                    when 10 => ALU_op <= "010";  -- AND
                    when 11 => ALU_op <= "011";  -- OR
                    when 12 => ALU_op <= "100";  -- XOR
                    when others => null;
                end case;
				report "ALU state reached" severity note;

            when 13 =>  -- RT writeback
                RF_addr_wr  <= "01";
                RF_WregEn   <= '1';
				IRin          <=  '0';
				PCin          <=  '0';
				Ain        <= '0';
				ALU_op     <= "111";
				report "RT writeback state reached" severity note;

            when 14 =>  -- st/ld decide
				bus_ctrl_r    <= "1000";  -- RF_out
				RF_addr_rd  <= "10"; -- sum rb with REG A
				Ain         <= '0';  -- load rb to reg A by ALU
				IRin          <=  '0';
				ALU_op       <= "000"; -- for rb load and ADD
				PCin          <=  '0';
				DTCM_addr_out <= '1';
				DTCM_addr_in      <= '1';
				report "ST/LD decide writeback state reached" severity note;

            when 15 =>  -- ST phase 1 (need to make sure bus_a to readAddr
				RF_addr_rd		<= "01";
				bus_ctrl_r			<= "1000";
				IRin          <=  '0';
				PCin          <=  '0';
				Ain        <= '0';
				DTCM_addr_in      <= '0';
				report "ST1 writeback state reached" severity note;				

            when 16 =>  -- ST → memory write
                bus_ctrl_r			<= "1000";
				DTCM_wr 	  		<= '1'; -- allows us  to load into data memory
 -- allows the address of the store to be used in mux (need to create mux)
				IRin          <=  '0';
				PCin          <=  '0';
				Ain        <= '0';
				ALU_op		<= "111";
				report "ST2 writeback state reached" severity note;
				
            when 17 =>  -- LD phase 1 
				PCin          <=  '0';
				IRin          <=  '0';
				Ain        	  <= '0';
--				ALU_op         <=  "111";
				bus_ctrl_r		<= "0100";

				report "LD1 writeback state reached" severity note;
				

            when 18 =>  -- LD → register write 
                -- maybe add DTCM write

				Ain			<= '1';
				ALU_op         <=  "111";
				bus_ctrl_r		<= "0100";
				RF_WregEn		<= '1';
				RF_addr_wr	<= "01";
				IRin          <=  '0';
				--PCsel			<= "10"; -- PC + 1
				PCin          <=  '0';
				report "LD2 writeback state reached" severity note;
				

            when 19 =>  -- DEC (decode)
                -- Reset fetch lines (IRin, Pcin)
                IRin        <= '0';
                PCin        <= '0';
                PCsel       <= "00";
				Ain        <= '0';
				report "decode state reached" severity note;
				
			WHEN 20 => -- write from data mem to RF	
				Ain			<= '1';
				ALU_op         <=  "111";
				bus_ctrl_r		<= "0100";
				RF_WregEn		<= '1';
				RF_addr_wr	<= "01";
				IRin          <=  '0';
				--PCsel			<= "10"; -- PC + 1
				PCin          <=  '0';
			when 21 => -- write from bus b into datamem (store last phase)
				bus_ctrl_r			<= "1000";
				DTCM_wr 	  		<= '1'; -- allows us  to load into data memory
                DTCM_addr_in      <= '1'; -- allows the address of the store to be used in mux (need to create mux)
				IRin          <=  '0';
				PCin          <=  '0';
				Ain        <= '0';
				ALU_op		<= "111";
            when others =>
                -- Default no-op
                null;
        end case;
    end process;

    ----------------------------------------------------------
    -- Flag Register: Stores ALU flags for later decision use
    ----------------------------------------------------------
    FlagLogic: process(clk, rst)
        variable state_v : integer range 0 to 31;
    begin
        state_v := conv_integer(state);

        if rst = '1' then
            flags_q <= "000";
        elsif rising_edge(clk) then
            case state_v is
                when 8 | 9 => -- ADD or SUB
                    flags_q <= ALU_c & ALU_z & ALU_n;  -- C,Z,N
                when 10 | 11 | 12 => -- AND , OR or XOR
                    flags_q(1 downto 0) <= ALU_z & ALU_n;
                when others =>
                    null;
            end case;
        end if;
    end process;

	-- Status Bit Encoding: For external monitoring/debug
	-- Format: [MOV][DONE][AND][OR][XOR][JNC][JC][JMP][C][Z][N][LD][ST]
	-- Assign opcode-related bits (excluding bits 4:2)
	with opcode select
		status_bits(14 downto 5) <= "1000000000" when "1100", -- mov
									  "0100000000" when "1111", -- done
									  "0010000000" when "0010", -- and
									  "0001000000" when "0011", -- or
									  "0000100000" when "0100", -- xor
									  "0000010000" when "1001", -- jnc
									  "0000001000" when "1000", -- jc
									  "0000000100" when "0111", -- jmp
									  "0000000010" when "0001", -- SUB
									  "0000000001" when "0000", -- ADD
									  "0000000000" when others;

	-- Assign fixed status bits
	status_bits(4) <= flags_q(2);  -- Carry flag
	status_bits(3) <= flags_q(1);  -- Zero flag
	status_bits(2) <= flags_q(0);  -- Negative flag
	status_bits(1) <= '1' when opcode = "1101" else '0'; -- Load
	status_bits(0) <= '1' when opcode = "1110" else '0'; -- Store
	done <= done_r;
end ctrlArch;