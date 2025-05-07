library IEEE;
use ieee.std_logic_1164.all;

package aux_package is
--------------------------------------------------------	
-- Full Adder component declaration
--------------------------------------------------------	
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;

--------------------------------------------------------	

end package aux_package;
