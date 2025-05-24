library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
--------------------------------------------------------------
entity GenericRegister is
    generic(Dwidth : integer := 16); -- width of register
    port(
        clk   : in std_logic;
        ena   : in std_logic;
        rst   : in std_logic;
        d     : in std_logic_vector(Dwidth-1 downto 0);
        q     : out std_logic_vector(Dwidth-1 downto 0)
    );
end GenericRegister;
--------------------------------------------------------------
architecture RegArch of GenericRegister is
begin
    GenericReg_proc: process(clk, ena, rst, d)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif ena = '1' then
            if rising_edge(clk) then
                q <= d;
            end if;
        end if;
    end process;
end RegArch;