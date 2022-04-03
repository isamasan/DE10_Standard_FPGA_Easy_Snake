
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tabla_Y_pkg is
	type rom is array (0 to 8) of unsigned(8 downto 0);
	constant t1: rom;
end tabla_Y_pkg;

package body tabla_Y_pkg is
	constant t1: rom := ("000110000", "100100000", "011010000", "100110000", "001010000", "011110000", "001110000", "010100000", "001100000");
end package body tabla_Y_pkg;