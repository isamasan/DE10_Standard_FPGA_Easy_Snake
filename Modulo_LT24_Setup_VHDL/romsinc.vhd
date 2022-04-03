library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.romData_pkg.all;

entity romsinc is
  port (
    clk		: in  std_logic;
    addr	: in  std_logic_vector(6 downto 0);
    datout	: out std_logic_vector(11 downto 0)
  );
end entity romsinc;

architecture a of romsinc is
--   type rom_type is array (0 to (2**7)-1) of std_logic_vector(16 downto 0);
   signal rom : rom_type := Init128romData;
   signal read_addr : std_logic_vector(6 downto 0);
begin
  process(clk) is
  begin
    if (clk'event and clk='1') then
      read_addr <= addr;
    end if;
  end process;

  datout <= rom(to_integer(unsigned(read_addr)));

end architecture a;