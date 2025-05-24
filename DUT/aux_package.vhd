library IEEE;
use ieee.std_logic_1164.all;

package aux_package is


--------------------------------------------------------
-- StateLogic FSM component declaration
--------------------------------------------------------
	component StateLogic is
		generic(StateLength : integer := 5);
		port(
			clk           : in  std_logic;
			ena           : in  std_logic;
			rst           : in  std_logic;
			ALU_cflag     : in  std_logic;
			opcode        : in  std_logic_vector(3 downto 0);
			current_state : out std_logic_vector(StateLength-1 downto 0)
		);
	end component;
--------------------------------------------------------
-- IR component declaration
--------------------------------------------------------
	component IR is
		generic (Dwidth : integer := 16);
		port (
			clk         : in  std_logic;
			ena         : in  std_logic;
			rst         : in  std_logic;
			RF_addr_rd   : in  std_logic_vector(1 downto 0);
			RF_addr_wr   : in  std_logic_vector(1 downto 0);
			addr_rd, addr_wr   : out std_logic_vector(3 downto 0);
			IR_content  : in  std_logic_vector(Dwidth-1 downto 0);
			opcode      : out std_logic_vector(3 downto 0);
			signext1    : out std_logic_vector(Dwidth-1 downto 0);
			signext2    : out std_logic_vector(Dwidth-1 downto 0);
			imm_to_PC   : out std_logic_vector(7 downto 0)
		);
	end component;


--------------------------------------------------------
-- Generic Register component declaration
--------------------------------------------------------
	component GenericRegister is
		generic(Dwidth : integer := 16);
		port(
			clk   : in  std_logic;
			ena   : in  std_logic;
			rst   : in  std_logic;
			d    : in  std_logic_vector(Dwidth-1 downto 0);
			q   : out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- Full Adder component declaration
--------------------------------------------------------	
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;

--------------------------------------------------------	
--------------------------------------------------------
-- ControlUnit component declaration
--------------------------------------------------------
	component ControlUnit is
		generic(StateLength : integer := 5);
		port(
			-- Clock, Reset, Enable
			clk         : in std_logic;
			rst         : in std_logic;
			ena         : in std_logic;

			-- ALU status flags
			ALU_c       : in std_logic;
			ALU_z       : in std_logic;
			ALU_n       : in std_logic;

			-- Instruction opcode
			opcode      : in std_logic_vector(3 downto 0);

			-- Datapath control signals
			DTCM_wr       : out std_logic;
			DTCM_addr_sel : out std_logic;
			DTCM_addr_out : out std_logic;
			DTCM_addr_in  : out std_logic;
			DTCM_out      : out std_logic;
			ALU_op         : out std_logic_vector(2 downto 0);
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
			done			: out std_logic;

			-- Debug/status output
			status_bits   : out std_logic_vector(14 downto 0)
		);
	end component;

--------------------------------------------------------
-- ControlLines component declaration
--------------------------------------------------------
	component ControlLines is
		generic(StateLength : integer := 5);
		port(
			-- ControlUnit inputs
			clk        : in std_logic;
			rst        : in std_logic;
			ena        : in std_logic;
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
			ALU_op         : out std_logic_vector(2 downto 0);
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
			done            : out std_logic
		);
	end component;

--------------------------------------------------------
-- top component declaration
--------------------------------------------------------
	component top is
		generic(
			Dwidth      : integer := 16;
			Awidth      : integer := 6;
			dept        : integer := 64;
			StateLength : integer := 5
		);
		port(
			clk              : in std_logic;
			rst              : in std_logic;
			ena              : in std_logic;
			done             : out std_logic;


			
			-- TB inputs
			DTCM_tb_out        : out std_logic_vector(Dwidth-1 downto 0);
			tb_active        : in  std_logic;
			DTCM_tb_addr_in  : in  std_logic_vector(Awidth-1 downto 0);
			DTCM_tb_wr       : in  std_logic;
			DTCM_tb_addr_out : in  std_logic_vector(Awidth-1 downto 0);
			DTCM_tb_in       : in  std_logic_vector(Dwidth-1 downto 0);
			ITCM_tb_in       : in  std_logic_vector(Dwidth-1 downto 0);
			ITCM_tb_addr_in  : in  std_logic_vector(Awidth-1 downto 0);
			ITCM_tb_wr       : in  std_logic
		);
	end component;

--------------------------------------------------------
-- RF component declaration
--------------------------------------------------------
	component RF is
		generic(
			Dwidth : integer := 16;
			Awidth : integer := 4
		);
		port(
			clk       : in  std_logic;
			rst       : in  std_logic;
			WregEn    : in  std_logic;
			WregData  : in  std_logic_vector(Dwidth-1 downto 0);
			WregAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RregAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RregData  : out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;


--------------------------------------------------------
-- dataMem component declaration
--------------------------------------------------------
	component dataMem is
		generic(
			Dwidth : integer := 16;
			Awidth : integer := 6;
			dept   : integer := 64
		);
		port(
			clk       : in  std_logic;
			memEn     : in  std_logic;
			WmemData  : in  std_logic_vector(Dwidth-1 downto 0);
			WmemAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RmemAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RmemData  : out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;


--------------------------------------------------------
-- ProgMem component declaration
--------------------------------------------------------
	component ProgMem is
		generic(
			Dwidth : integer := 16;
			Awidth : integer := 6;
			dept   : integer := 64
		);
		port(
			clk       : in  std_logic;
			memEn     : in  std_logic;
			WmemData  : in  std_logic_vector(Dwidth-1 downto 0);
			WmemAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RmemAddr  : in  std_logic_vector(Awidth-1 downto 0);
			RmemData  : out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- ALU_main component declaration
--------------------------------------------------------
	component ALU_main is
		generic (Dwidth : integer := 16);
		port (
			reg_a_q   : in  std_logic_vector(Dwidth-1 downto 0);
			reg_b_r   : in  std_logic_vector(Dwidth-1 downto 0);
			i_ctrl	    : in  std_logic_vector(2 downto 0);
			Ain	 	: in  std_logic;
			result    : out std_logic_vector(Dwidth-1 downto 0);
			cflag     : out std_logic;
			nflag     : out std_logic;
			zflag     : out std_logic
		);
	end component;

--------------------------------------------------------
-- PCLogic component declaration
--------------------------------------------------------
	component PCLogic is
		generic(Awidth : integer := 6);
		port(
			clk         : in  std_logic;
			i_PCin        : in  std_logic;
			i_PCsel       : in  std_logic_vector(1 downto 0);
			IR_imm      : in  std_logic_vector(7 downto 0);
			currentPC   : out std_logic_vector(Awidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- BidirPin component declaration
--------------------------------------------------------
	component BidirPin is
		generic(Dwidth : integer := 16);
		port(
			i_data    : in    std_logic_vector(Dwidth-1 downto 0);
			enable_out      : in    std_logic;
			o_data   : inout std_logic_vector(Dwidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- BidirPinBasic component declaration
--------------------------------------------------------
	component BidirPinBasic is
		port(
			writePin : in  std_logic;
			readPin  : out std_logic;
			bidirPin : inout std_logic
		);
	end component;

--------------------------------------------------------
-- Datapath component declaration
--------------------------------------------------------
	component Datapath is
		generic(
			Dwidth : integer := 16;
			Awidth : integer := 6;
			dept   : integer := 64
		);
		port(
			clk               : in std_logic;
			ena               : in std_logic;
			rst				: in std_logic;
			
			alu_c             : out std_logic;
			alu_z             : out std_logic;
			alu_n             : out std_logic;
			opcode            : out std_logic_vector(3 downto 0);

			-- control signals
			DTCM_wr           : in std_logic;
			DTCM_addr_sel     : in std_logic;		
			DTCM_addr_out     : in std_logic;	
			DTCM_addr_in      : in std_logic;		
			DTCM_out          : in std_logic;
			ALU_op             : in std_logic_vector(2 downto 0); 
			Ain               : in std_logic;
			RF_WregEn         : in std_logic;
			RF_out            : in std_logic;
			RF_addr_rd        : in std_logic_vector(1 downto 0);
			RF_addr_wr        : in std_logic_vector(1 downto 0);		
			IRin              : in std_logic;
			PCin              : in std_logic;
			PCsel             : in std_logic_vector(1 downto 0);
			Imm1_in           : in std_logic;
			Imm2_in           : in std_logic;	

			-- TB inputs/outputs
			DTCM_tb_out         : out std_logic_vector(Dwidth-1 downto 0);
			tb_active         : in std_logic;
			DTCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
			DTCM_tb_addr_out  : in std_logic_vector(Awidth-1 downto 0);
			DTCM_tb_wr        : in std_logic;
			DTCM_tb_in        : in std_logic_vector(Dwidth-1 downto 0);
			ITCM_tb_in        : in std_logic_vector(Dwidth-1 downto 0);
			ITCM_tb_addr_in   : in std_logic_vector(Awidth-1 downto 0);
			ITCM_tb_wr        : in std_logic
						
		);
	end component;

end package aux_package;