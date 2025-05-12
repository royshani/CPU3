library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aux_package.all;

entity ALU_main is
    generic (Dwidth : integer := 16);
    port (
        reg_a_q_i : in  std_logic_vector(Dwidth-1 downto 0);
        reg_b_r_i : in  std_logic_vector(Dwidth-1 downto 0);
        alu_op_i  : in  std_logic_vector(2 downto 0);
		Ain_i	  : in	std_logic;
        result_o  : out std_logic_vector(Dwidth-1 downto 0);
        cflag_o   : out std_logic;
        nflag_o   : out std_logic;
        zflag_o   : out std_logic
    );
end ALU_main;

-------------------------------------------------------------------
-- PURE LOGIC ALU UNIT - BASED UPON LAB 1 ADDERSUB SUB-MODULE -----
-- NOTE: unused opcodes currently are set to output zero vector --
-------------------------------------------------------------------
architecture ALUarch of ALU_main is

    component FA is
        port (
            xi, yi, cin : in  std_logic;
            s, cout     : out std_logic
        );
    end component;

    signal ripple_w, addsub_r : std_logic_vector(Dwidth-1 downto 0);
    signal cin_r         : std_logic;
    signal manip_b_r     : std_logic_vector(Dwidth-1 downto 0);
    signal alu_result_r  : std_logic_vector(Dwidth-1 downto 0);
    signal zero_w        : std_logic_vector(Dwidth-1 downto 0) := (others => '0');
    signal alu_a_r, alu_b_r : std_logic_vector(Dwidth-1 downto 0);

begin
    -- Internal assignments
    alu_a_r <= reg_a_q_i;
    alu_b_r <= reg_b_r_i;

    manip_b_r <= not reg_b_r_i when alu_op_i = "001" else reg_b_r_i;
    cin_r     <= '1' when alu_op_i = "001" else '0';

    -- Ripple Carry Adder/Subtractor --
    MapFirstFA : FA port map (
        xi   => manip_b_r(0),
        yi   => reg_a_q_i(0),
        cin  => cin_r,
        s    => addsub_r(0),
        cout => ripple_w(0)
    );

    MapRestFA : for i in 1 to Dwidth-1 generate
        chain : FA port map (
            xi   => manip_b_r(i),
            yi   => reg_a_q_i(i),
            cin  => ripple_w(i-1),
            s    => addsub_r(i),
            cout => ripple_w(i)
        );
    end generate;

    -- Output logic and flag assignment
    with alu_op_i select
        alu_result_r <= addsub_r           when "000",  -- ADD
                         addsub_r           when "001",  -- SUB
                         reg_a_q_i and reg_b_r_i when "010",  -- AND
                         reg_a_q_i or  reg_b_r_i when "011",  -- OR
                         reg_a_q_i xor reg_b_r_i when "100",  -- XOR
						 (others => '0') 	  when "101", -- unused opcode for now (5)
						 (others => '0') 	  when "110", -- unused opcode for now (6)
						 reg_b_r_i when "111" and i_Ain = "1", -- move rb to REG A
                         (others => '0')         when others;  -- Default unused opcodes

    nflag_o <= alu_result_r(Dwidth-1);
    zflag_o <= '1' when alu_result_r = zero_w else '0';
    cflag_o <= ripple_w(Dwidth-1) when (alu_op_i = "000" or alu_op_i = "001") else '0';
    result_o <= alu_result_r;

end ALUarch;
