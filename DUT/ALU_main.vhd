library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aux_package.all;
entity ALU_main is
    generic (Dwidth : integer := 16);
    port (
        i_A     : in  std_logic_vector(Dwidth-1 downto 0);
        i_B     : in  std_logic_vector(Dwidth-1 downto 0);
        i_ALUFN : in  std_logic_vector(2 downto 0);
        BUS_A_Data : out std_logic_vector(Dwidth-1 downto 0); -- changed to support 2 bus
        o_cflag : out std_logic;
        o_nflag : out std_logic;
        o_zflag : out std_logic
    );
end ALU_main;
-------------------------------------------------------------------
-- PURE LOGIC ALU UNIT - BASED UPON LAB 1 ADDERSUB SUB-MODULE -----
-- NOTE: unused opcodes currently are set to ouput High-Z vector --
-------------------------------------------------------------------
architecture ALUarch of ALU_main is

    component FA is
        port (
            xi, yi, cin : in  std_logic;
            s, cout     : out std_logic
        );
    end component;

    signal Ripple_reg, AdderSub_result : std_logic_vector(Dwidth-1 downto 0);
    signal cin         : std_logic;
    signal manip_B     : std_logic_vector(Dwidth-1 downto 0);
    signal ALU_result  : std_logic_vector(Dwidth-1 downto 0);
    signal zero_vector : std_logic_vector(Dwidth-1 downto 0) := (others => '0');
	signal ALU_A, ALU_B: std_logic_vector(Dwidth-1 downto 0); -- internal vectors

begin
	-- setting up interal signals --
	ALU_A <= i_A; -- by default if i_A is not valid, it will assign 0 vector
	ALU_B <= i_B; -- by default if i_A is not valid, it will assign 0 vector
	--
	--zero_signal <= (others => '0');
    manip_B <= not i_B when i_ALUFN = "001" else i_B; -- when sub is selected add with the neg number
    cin     <= '1' when i_ALUFN = "001" else '0'; 

	-- same Ripple Adder as seen in example from tutorials --
	MapFirstFA : FA port map (
        xi   => manip_B(0),
        yi   => i_A(0),
        cin  => cin,
        s    => AdderSub_result(0),
        cout => Ripple_reg(0)
	);
	MapRestFA : for i in 1 to Dwidth-1 generate
		chain : FA port map (
            xi   => manip_B(i),
            yi   => i_A(i),
            cin  => Ripple_reg(i-1),
            s    => AdderSub_result(i),
            cout => Ripple_reg(i)
		);
	end generate;


	---- flags and output MUXing ----
	with i_ALUFN select
		ALU_result <= AdderSub_result     when "000",  -- ADD
					  AdderSub_result     when "001",  -- SUB
					  i_A and i_B         when "010",  -- AND
					  i_A or  i_B         when "011",  -- OR
					  i_A xor i_B         when "100",  -- XOR
					  (others => '0') 	  when "101", -- unused opcode for now (5)
					  (others => '0') 	  when "110", -- unused opcode for now (6)
					  (others => '0') 	  when "111", -- CHECK IF Z OR 0
					  (others => '0') 	  when others; -- changed from 'z' to '0' by HANAN instruction
	
	o_nflag <= ALU_result(Dwidth-1);
	o_zflag <= '1' when ALU_result = zero_vector else '0';
	o_cflag <= Ripple_reg(Dwidth-1) when (i_ALUFN="000" or i_ALUFN="001") else '0';
	BUS_A_Data <= ALU_result;

end ALUarch;
