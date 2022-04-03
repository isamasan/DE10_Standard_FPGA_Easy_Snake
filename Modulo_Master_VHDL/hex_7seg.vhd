library ieee;
use ieee.std_logic_1164.all;

entity hex_7seg is
  port (
    hex : in  std_logic_vector (3 downto 0);
    dig : out std_logic_vector (6 downto 0)
  );
end hex_7seg;

architecture arch_hex_7seg of hex_7seg is

  begin

  process (hex)
    begin
      case hex is
        when x"0"   => dig <= "1000000";
        when x"1"   => dig <= "1111001";
        when x"2"   => dig <= "0100100";
        when x"3"   => dig <= "0110000";
        when x"4"   => dig <= "0011001";
        when x"5"   => dig <= "0010010";
        when x"6"   => dig <= "0000010";
        when x"7"   => dig <= "1111000";
        when x"8"   => dig <= "0000000";
        when x"9"   => dig <= "0010000";
        when x"a"   => dig <= "0001000";
        when x"b"   => dig <= "0000011";
        when x"c"   => dig <= "1000110";
        when x"d"   => dig <= "0100001";
        when x"e"   => dig <= "0000110";
        when x"f"   => dig <= "0001110";
        when others => dig <= "1111111";
      end case;
    end process;

end arch_hex_7seg;
