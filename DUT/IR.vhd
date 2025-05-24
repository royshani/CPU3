library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
--------------------------------------------------------------
entity IR is
    generic(Dwidth : integer := 16); -- Instruction register width
    port(
        clk        : in std_logic;
        ena        : in std_logic;  -- enable = IRin
        rst        : in std_logic;  -- reset = system_rst
        RF_addr_rd  : in std_logic_vector(1 downto 0);
		RF_addr_wr  : in std_logic_vector(1 downto 0);
        IR_content  : in std_logic_vector(Dwidth-1 downto 0);
		addr_rd, addr_wr   : out std_logic_vector(3 downto 0);
        opcode      : out std_logic_vector(3 downto 0);
        signext1    : out std_logic_vector(Dwidth-1 downto 0);
        signext2    : out std_logic_vector(Dwidth-1 downto 0);
        imm_to_PC   : out std_logic_vector(7 downto 0)
    );
end IR;
--------------------------------------------------------------
architecture IRArch of IR is
    -- IR internal register
    signal IR_q : std_logic_vector(Dwidth-1 downto 0);
    -- Extracted fields
    signal ra_r, rb_r, rc_r       : std_logic_vector(3 downto 0);
    signal immShort_r             : std_logic_vector(3 downto 0);
    signal immLong_r              : std_logic_vector(7 downto 0);
begin
    -- Instruction register load logic
    InstructionReg_proc: process(clk,ena,IR_content,rst)
    begin
		if rst = '1' then
			IR_q <= (others => '0');
		elsif ena = '1' then
			if rising_edge(clk) then
				IR_q <= IR_content;
			end if;
		end if;
    end process;
    -- Field extraction from IR register
    opcode     <= IR_q(15 downto 12);
    ra_r         <= IR_q(11 downto 8);
    rb_r         <= IR_q(7 downto 4);
    rc_r         <= IR_q(3 downto 0);
    immShort_r   <= IR_q(3 downto 0);
    immLong_r    <= IR_q(7 downto 0);
    imm_to_PC  <= IR_q(7 downto 0);
    -- Register File address selection
    with RF_addr_rd select -- choose which reg to read from
        addr_rd <= ra_r when "01",
                  rb_r when "10",
                  rc_r when "11",
                  "0000" when others;
				  
	with RF_addr_wr select -- choose which reg to write to
        addr_wr <= ra_r when "01",
                  rb_r when "10",
                  rc_r when "11",
                  "0000" when others;
    -- Sign-extension of 4-bit immediate
    signext2(3 downto 0) <= immShort_r;
    with immShort_r(3) select
        signext2(Dwidth-1 downto 4) <= (others => '1') when '1',
                                         (others => '0') when others;
    -- Sign-extension of 8-bit immediate
    signext1(7 downto 0) <= immLong_r;
    with immLong_r(7) select
        signext1(Dwidth-1 downto 8) <= (others => '1') when '1',
                                         (others => '0') when others;
end IRArch;