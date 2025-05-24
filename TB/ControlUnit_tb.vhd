library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_ControlUnit is
end tb_ControlUnit;

architecture sim of tb_ControlUnit is
    -- Constants
    constant clk_period : time := 10 ns;

    -- DUT ports
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal ena         : std_logic := '0';
    signal ALU_c       : std_logic := '0';
    signal ALU_z       : std_logic := '0';
    signal ALU_n       : std_logic := '0';
    signal done        : std_logic;
    signal opcode      : std_logic_vector(3 downto 0) := (others => '0');
    signal RF_addr_rd  : std_logic_vector(1 downto 0);
    signal RF_addr_wr  : std_logic_vector(1 downto 0);
    signal DTCM_wr     : std_logic;
    signal DTCM_addr_sel : std_logic;
    signal DTCM_addr_out : std_logic;
    signal DTCM_addr_in  : std_logic;
    signal DTCM_out      : std_logic;
    signal ALU_op        : std_logic_vector(2 downto 0);
    signal Ain           : std_logic;
    signal RF_WregEn     : std_logic;
    signal RF_out        : std_logic;
    signal IRin          : std_logic;
    signal PCin          : std_logic;
    signal PCsel         : std_logic_vector(1 downto 0);
    signal Imm1_in       : std_logic;
    signal Imm2_in       : std_logic;
    signal status_bits   : std_logic_vector(14 downto 0);

begin
    -- Clock generation
    clk <= not clk after clk_period / 2;

    -- DUT Instantiation
    DUT: entity work.ControlUnit
        generic map(StateLength => 5)
        port map (
            clk           => clk,
            rst           => rst,
            ena           => ena,
            ALU_c         => ALU_c,
            ALU_z         => ALU_z,
            ALU_n         => ALU_n,
            done          => done,
            opcode        => opcode,
            RF_addr_rd    => RF_addr_rd,
            RF_addr_wr    => RF_addr_wr,
            DTCM_wr       => DTCM_wr,
            DTCM_addr_sel => DTCM_addr_sel,
            DTCM_addr_out => DTCM_addr_out,
            DTCM_addr_in  => DTCM_addr_in,
            DTCM_out      => DTCM_out,
            ALU_op        => ALU_op,
            Ain           => Ain,
            RF_WregEn     => RF_WregEn,
            RF_out        => RF_out,
            IRin          => IRin,
            PCin          => PCin,
            PCsel         => PCsel,
            Imm1_in       => Imm1_in,
            Imm2_in       => Imm2_in,
            status_bits   => status_bits
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset and enable
        rst <= '1';
        ena <= '0';
        wait for 2 * clk_period;
        rst <= '0';
        ena <= '1';

        -- Test different opcodes
        for i in 0 to 15 loop
            opcode <= std_logic_vector(to_unsigned(i, 4));
            ALU_c <= '0'; ALU_z <= '0'; ALU_n <= '0';
            wait for 8 * clk_period;

            -- Simulate some flag conditions
            ALU_c <= '1'; ALU_z <= '0'; ALU_n <= '0';
            wait for 2 * clk_period;
            ALU_c <= '0'; ALU_z <= '1'; ALU_n <= '0';
            wait for 2 * clk_period;
            ALU_c <= '0'; ALU_z <= '0'; ALU_n <= '1';
            wait for 2 * clk_period;
        end loop;

        -- End simulation
        wait for 10 * clk_period;
        assert false report "Simulation complete." severity failure;
    end process;

end sim;
