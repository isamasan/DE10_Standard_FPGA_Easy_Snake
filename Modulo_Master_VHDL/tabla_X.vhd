library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tabla_X_pkg is
	type rom is array (0 to 8) of unsigned(7 downto 0);
	constant t2: rom;
end tabla_X_pkg;

package body tabla_X_pkg is
	constant t2: rom := ("00100000", "01110000", "01000000", "10100000", "10110000", "10000000", "10010000", "01100000", "00110000");
end package body tabla_X_pkg;
