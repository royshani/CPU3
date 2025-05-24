library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_Datapath is
end tb_Datapath;

architecture behavior of tb_Datapath is

    -- Constants
    constant Dwidth : integer := 16;
    constant Awidth : integer := 6;
    constant dept   : integer := 64;

    -- Signals
    signal clk               : std_logic := '0';
    signal ena               : std_logic := '0';
    signal rst               : std_logic := '0';

    signal alu_c             : std_logic;
    signal alu_z             : std_logic;
    signal alu_n             : std_logic;
    signal opcode            : std_logic_vector(3 downto 0);

    signal DTCM_wr           : std_logic := '0';
    signal DTCM_addr_sel     : std_logic := '0';
    signal DTCM_addr_out     : std_logic := '0';
    signal DTCM_addr_in      : std_logic := '0';
    signal DTCM_out          : std_logic := '0';
    signal ALU_op            : std_logic_vector(2 downto 0) := (others => '0');
    signal Ain               : std_logic := '0';
    signal RF_WregEn         : std_logic := '0';
    signal RF_out            : std_logic := '0';
    signal RF_addr_rd        : std_logic_vector(1 downto 0) := (others => '0');
    signal RF_addr_wr        : std_logic_vector(1 downto 0) := (others => '0');
    signal IRin              : std_logic := '0';
    signal PCin              : std_logic := '0';
    signal PCsel             : std_logic_vector(1 downto 0) := (others => '0');
    signal Imm1_in           : std_logic := '0';
    signal Imm2_in           : std_logic := '0';

    signal DTCM_tb_out       : std_logic_vector(Dwidth-1 downto 0);
    signal tb_active         : std_logic := '0';
    signal DTCM_tb_addr_in   : std_logic_vector(Awidth-1 downto 0) := (others => '0');
    signal DTCM_tb_addr_out  : std_logic_vector(Awidth-1 downto 0) := (others => '0');
    signal DTCM_tb_wr        : std_logic := '0';
    signal DTCM_tb_in        : std_logic_vector(Dwidth-1 downto 0) := (others => '0');
    signal ITCM_tb_in        : std_logic_vector(Dwidth-1 downto 0) := (others => '0');
    signal ITCM_tb_addr_in   : std_logic_vector(Awidth-1 downto 0) := (others => '0');
    signal ITCM_tb_wr        : std_logic := '0';

begin

    -- Clock generation
    clk_process : process
    begin
        while now < 1 ms loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.Datapath
        generic map(
            Dwidth => Dwidth,
            Awidth => Awidth,
            dept => dept
        )
        port map(
            clk => clk,
            ena => ena,
            rst => rst,
            alu_c => alu_c,
            alu_z => alu_z,
            alu_n => alu_n,
            opcode => opcode,
            DTCM_wr => DTCM_wr,
            DTCM_addr_sel => DTCM_addr_sel,
            DTCM_addr_out => DTCM_addr_out,
            DTCM_addr_in => DTCM_addr_in,
            DTCM_out => DTCM_out,
            ALU_op => ALU_op,
            Ain => Ain,
            RF_WregEn => RF_WregEn,
            RF_out => RF_out,
            RF_addr_rd => RF_addr_rd,
            RF_addr_wr => RF_addr_wr,
            IRin => IRin,
            PCin => PCin,
            PCsel => PCsel,
            Imm1_in => Imm1_in,
            Imm2_in => Imm2_in,
            DTCM_tb_out => DTCM_tb_out,
            tb_active => tb_active,
            DTCM_tb_addr_in => DTCM_tb_addr_in,
            DTCM_tb_addr_out => DTCM_tb_addr_out,
            DTCM_tb_wr => DTCM_tb_wr,
            DTCM_tb_in => DTCM_tb_in,
            ITCM_tb_in => ITCM_tb_in,
            ITCM_tb_addr_in => ITCM_tb_addr_in,
            ITCM_tb_wr => ITCM_tb_wr
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset sequence
        rst <= '1'; wait for 20 ns;
        rst <= '0'; ena <= '1'; wait for 20 ns;

        -- Load instruction into ITCM
        tb_active <= '1';
        ITCM_tb_wr <= '1';
        ITCM_tb_addr_in <= "000001"; -- address 1
        ITCM_tb_in <= x"1023";       -- dummy instruction
        wait for 20 ns;

        -- Clear write
        ITCM_tb_wr <= '0';

        -- Activate PC logic
        PCin <= '1'; wait for 20 ns;
        PCin <= '0'; wait for 20 ns;

        -- Enable instruction register
        IRin <= '1'; wait for 20 ns;
        IRin <= '0'; wait for 20 ns;

        -- Example ALU operation (just toggling signals to observe behavior)
        Ain <= '1';
        ALU_op <= "001";
        wait for 20 ns;
        Ain <= '0';

        -- Simulate memory write
        tb_active <= '0';
        DTCM_addr_in <= '1';
        DTCM_addr_sel <= '0';
        DTCM_wr <= '1';
        wait for 20 ns;
        DTCM_wr <= '0';

        wait;
    end process;

end behavior;
