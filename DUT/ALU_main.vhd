library IEEE;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
USE work.aux_package.all;
USE ieee.numeric_std.all;

entity ALU_main is
    generic (Dwidth : integer := 16);
    port (
        reg_a_q : in  std_logic_vector(Dwidth-1 downto 0);
        reg_b_r : in  std_logic_vector(Dwidth-1 downto 0);
        i_ctrl  : in  std_logic_vector(2 downto 0);
		Ain	  : in	std_logic;
        result  : out std_logic_vector(Dwidth-1 downto 0);
        cflag   : out std_logic;
        nflag   : out std_logic;
        zflag   : out std_logic
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
    alu_a_r <= reg_a_q;
    alu_b_r <= reg_b_r;

    manip_b_r <= not alu_b_r when i_ctrl = "001" else alu_b_r;
    cin_r     <= '1' when i_ctrl = "001" else '0';

    -- Ripple Carry Adder/Subtractor --
    MapFirstFA : FA port map (
        xi   => manip_b_r(0),
        yi   => reg_a_q(0),
        cin  => cin_r,
        s    => addsub_r(0),
        cout => ripple_w(0)
    );

    MapRestFA : for i in 1 to Dwidth-1 generate
        chain : FA port map (
            xi   => manip_b_r(i),
            yi   => reg_a_q(i),
            cin  => ripple_w(i-1),
            s    => addsub_r(i),
            cout => ripple_w(i)
        );
    end generate;

	alu_result_r <= 
		addsub_r            when i_ctrl = "000" else
		addsub_r            when i_ctrl = "001" else
		(reg_a_q and reg_b_r) when i_ctrl = "010" else
		(reg_a_q or  reg_b_r) when i_ctrl = "011" else
		(reg_a_q xor reg_b_r) when i_ctrl = "100" else
		reg_b_r             when i_ctrl = "111" and Ain = '1' else
		alu_result_r;


			

    nflag <= alu_result_r(Dwidth-1);
    zflag <= '1' when alu_result_r = zero_w else '0';
    cflag <= ripple_w(Dwidth-1) when (i_ctrl = "000" or i_ctrl = "001") else '0';
    result <= alu_result_r;

end ALUarch;
