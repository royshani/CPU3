library IEEE;
use ieee.std_logic_1164.all;

package aux_package is


--------------------------------------------------------
-- StateLogic FSM component declaration
--------------------------------------------------------
	component StateLogic is
		generic(StateLength : integer := 5);
		port(
			clk_i           : in  std_logic;
			ena_i           : in  std_logic;
			rst_i           : in  std_logic;
			ALU_cflag_i     : in  std_logic;
			opcode_i        : in  std_logic_vector(3 downto 0);
			current_state_o : out std_logic_vector(StateLength-1 downto 0)
		);
	end component;
--------------------------------------------------------
-- IR component declaration
--------------------------------------------------------
component IR is
    generic (Dwidth : integer := 16);
    port (
        clk_i         : in  std_logic;
        ena_i         : in  std_logic;
        rst_i         : in  std_logic;
        RFaddr_rd_i   : in  std_logic_vector(1 downto 0);
        RFaddr_wr_i   : in  std_logic_vector(1 downto 0);
        IR_content_i  : in  std_logic_vector(Dwidth-1 downto 0);

        opcode_o      : out std_logic_vector(3 downto 0);
        addr_o        : out std_logic_vector(3 downto 0);
        signext1_o    : out std_logic_vector(Dwidth-1 downto 0);
        signext2_o    : out std_logic_vector(Dwidth-1 downto 0);
        imm_to_PC_o   : out std_logic_vector(7 downto 0)
    );
end component;


--------------------------------------------------------
-- Generic Register component declaration
--------------------------------------------------------
	component GenericRegister is
		generic(Dwidth : integer := 16);
		port(
			clk_i   : in  std_logic;
			ena_i   : in  std_logic;
			rst_i   : in  std_logic;
			d_i    : in  std_logic_vector(Dwidth-1 downto 0);
			q_o   : out std_logic_vector(Dwidth-1 downto 0)
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
			clk_i           : in  std_logic;
			rst_i           : in  std_logic;
			ena_i           : in  std_logic;

			ALU_c_i         : in  std_logic;
			ALU_z_i         : in  std_logic;
			ALU_n_i         : in  std_logic;

			opcode_i        : in  std_logic_vector(3 downto 0);

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
			status_bits_o   : out std_logic_vector(12 downto 0)
		);
	end component;
--------------------------------------------------------
-- ControlLines component declaration
--------------------------------------------------------
	component ControlLines is
		generic(StateLength : integer := 5);
		port(
			clk_i           : in  std_logic;
			rst_i           : in  std_logic;
			state_i         : in  std_logic_vector(StateLength-1 downto 0);
			opcode_i        : in  std_logic_vector(3 downto 0);
			ALU_c_i         : in  std_logic;
			ALU_z_i         : in  std_logic;
			ALU_n_i         : in  std_logic;

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

			cflag_o         : out std_logic;
			zflag_o         : out std_logic;
			nflag_o         : out std_logic;
			status_bits_o   : out std_logic_vector(9 downto 0)
		);
	end component;

--------------------------------------------------------
-- Top-level integration component declaration
--------------------------------------------------------
	component top is
		generic(
			Dwidth      : integer := 16;
			Awidth      : integer := 6;
			dept        : integer := 64;
			StateLength : integer := 5
		);
		port(
			clk_i              : in std_logic;
			rst_i              : in std_logic;
			ena_i              : in std_logic;
			done_o             : out std_logic_vector(1 downto 0);

			data_in_i          : in std_logic_vector(Dwidth-1 downto 0);
			prog_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);
			prog_wr_en_i       : in std_logic;
			tb_active_i        : in std_logic;
			data_wr_addr_i     : in std_logic_vector(Awidth-1 downto 0);
			data_wr_data_i     : in std_logic_vector(Dwidth-1 downto 0);
			data_wr_en_i       : in std_logic;
			data_rd_data_o     : out std_logic_vector(Dwidth-1 downto 0);
			data_rd_addr_i     : in std_logic_vector(Awidth-1 downto 0)
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
			clk_i      : in  std_logic;
			rst_i      : in  std_logic;
			WregEn_i   : in  std_logic;
			WregData_i : in  std_logic_vector(Dwidth-1 downto 0);
			WregAddr_i : in  std_logic_vector(Awidth-1 downto 0);
			RregAddr_i : in  std_logic_vector(Awidth-1 downto 0);
			RregData_o : out std_logic_vector(Dwidth-1 downto 0)
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
			clk_i       : in  std_logic;
			memEn_i     : in  std_logic;
			WmemData_i  : in  std_logic_vector(Dwidth-1 downto 0);
			WmemAddr_i  : in  std_logic_vector(Awidth-1 downto 0);
			RmemAddr_i  : in  std_logic_vector(Awidth-1 downto 0);
			RmemData_o  : out std_logic_vector(Dwidth-1 downto 0)
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
			clk_i       : in  std_logic;
			memEn_i     : in  std_logic;
			WmemData_i  : in  std_logic_vector(Dwidth-1 downto 0);
			WmemAddr_i  : in  std_logic_vector(Awidth-1 downto 0);
			RmemAddr_i  : in  std_logic_vector(Awidth-1 downto 0);
			RmemData_o  : out std_logic_vector(Dwidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- ALU_main component declaration
--------------------------------------------------------
	component ALU_main is
		generic (Dwidth : integer := 16);
		port (
			reg_a_q_i   : in  std_logic_vector(Dwidth-1 downto 0);
			reg_b_r_i   : in  std_logic_vector(Dwidth-1 downto 0);
			alu_op_i    : in  std_logic_vector(2 downto 0);
			Ain_i	 	: in  std_logic;
			result_o    : out std_logic_vector(Dwidth-1 downto 0);
			cflag_o     : out std_logic;
			nflag_o     : out std_logic;
			zflag_o     : out std_logic
		);
	end component;

--------------------------------------------------------
-- PCLogic component declaration
--------------------------------------------------------
	component PCLogic is
		generic(Awidth : integer := 6);
		port(
			clk_i         : in  std_logic;
			PCin_i        : in  std_logic;
			PCsel_i       : in  std_logic_vector(1 downto 0);
			IR_imm_i      : in  std_logic_vector(7 downto 0);
			currentPC_o   : out std_logic_vector(Awidth-1 downto 0)
		);
	end component;

--------------------------------------------------------
-- BidirPin component declaration
--------------------------------------------------------
	component BidirPin is
		generic(width : integer := 16);
		port(
			Dout_i  : in    std_logic_vector(width-1 downto 0);
			en_i    : in    std_logic;
			Din_o   : out   std_logic_vector(width-1 downto 0);
			IOpin   : inout std_logic_vector(width-1 downto 0)
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
			clk_i              : in  std_logic;
			data_in_i          : in  std_logic_vector(Dwidth-1 downto 0);
			prog_wr_addr_i     : in  std_logic_vector(Awidth-1 downto 0);
			prog_wr_en_i       : in  std_logic;
			tb_active_i        : in  std_logic;
			data_wr_addr_i     : in  std_logic_vector(Awidth-1 downto 0);
			data_wr_data_i     : in  std_logic_vector(Dwidth-1 downto 0);
			data_wr_en_i       : in  std_logic;
			data_rd_data_o     : out std_logic_vector(Dwidth-1 downto 0);
			data_rd_addr_i     : in  std_logic_vector(Awidth-1 downto 0);

			alu_c_o            : out std_logic;
			alu_z_o            : out std_logic;
			alu_n_o            : out std_logic;
			opcode_o           : out std_logic_vector(3 downto 0);

			RF_out_i           : in  std_logic;
			data_mem_out_i     : in  std_logic;
			Cout_i             : in  std_logic;
			Imm2_in_i          : in  std_logic;
			Imm1_in_i          : in  std_logic;
			IRin_i             : in  std_logic;
			RF_addr_i          : in  std_logic_vector(1 downto 0);
			PCsel_i            : in  std_logic_vector(1 downto 0);
			RF_WregEn_i        : in  std_logic;
			RF_rst_i           : in  std_logic;
			Ain_i              : in  std_logic;
			Cin_i              : in  std_logic;
			Mem_in_i           : in  std_logic;
			data_MemEn_i       : in  std_logic;
			PCin_i             : in  std_logic;
			ALU_op_i           : in  std_logic_vector(2 downto 0)
		);
	end component;


end package aux_package;
