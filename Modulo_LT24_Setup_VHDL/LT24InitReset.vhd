-----------------------------------------------------
--  Project sample
--
-------------------------------------------------------
--
-- CLOCK_50 is the system clock.
-- KEY0 is the active-low system reset.
-- LCD withouth touch screen
-- 
---------------------------------------------------------------
--- Realizado por: G.A.
--- Fecha: 07/07/2021
--
--- Version: V0.0  LT24 Reset sequence 
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.romData_pkg.all;

entity LT24InitReset is
  port (
    clk		: in  std_logic;
    reset_l	 :in  std_logic;

    Reset_Done	: out std_logic;
    
    LT24_RESET_N	: out std_logic;
    LT24_LCD_ON 	: out std_logic

  );
end entity LT24InitReset;

architecture a of LT24InitReset is
--   type rom_type is array (0 to (2**7)-1) of std_logic_vector(16 downto 0);
   type t_estado is (e_init, e_wait00, e_wait0, e_wait1, e_wait2, e_done );
   signal ep, es       : t_estado;

	constant PERIOD_CLK 	: time := 20 ns;
	constant USEC	 		: time := 1 us;
	constant TICS_PER_USEC		: integer := USEC / PERIOD_CLK; 
	
	constant MSEC	 		: time := 1 ms;
	constant TICS_PER_MSEC		: integer := MSEC / PERIOD_CLK;
	
	constant SECOND 		: time := 1 sec;
	constant TICS_PER_SECOND	: integer := SECOND / PERIOD_CLK;
	
	signal 	NumTicsXuSec 		: unsigned(7 downto 0);	-- Contador de TICs de clk
	signal  TicuSec			: std_logic;			-- Ha pasado 1 usec (se activa solo 1 ciclo de clk)
	
	signal 	NumTicsXmSec 		: unsigned(31 downto 0);	-- Contador de TICs de clk
	signal  TicmSec			: std_logic;			-- Ha pasado 1 msec (se activa solo 1 ciclo de clk)
	
	signal 	NumTicsXSecond 		: unsigned(31 downto 0);	-- Contador de TICs de clk
	signal  TicSec			: std_logic;			-- Ha pasado 1 segundo (se activa solo 1 ciclo de clk)



	signal  Init_TicsCounters			: std_logic;			-- Inic Tic Counters
	
	signal  to_5msec			: std_logic;			-- Ha pasado 1 ms  (se activa solo 1 ciclo de clk)
	signal  to_15usec			: std_logic;			-- Ha pasado 15 us  (se activa solo 1 ciclo de clk)
	signal  to_10usec			: std_logic;			-- Ha pasado 10 us (se activa solo 1 ciclo de clk)
	signal    divclk : unsigned(8 downto 0);
	attribute noprune: boolean;
	attribute noprune of divclk: signal is true;
	
	 signal addr	:  std_logic_vector(6 downto 0);
    signal datout	:  std_logic_vector(11 downto 0);
	 
	signal  LT24_Reset_Done			: std_logic;			-- Inic Tic Counters
	signal  tmp_LT24_RESET_N			: std_logic;			-- tmp_LT24_RESET_N
	
	signal 	cont_15usec 		: unsigned(7 downto 0);	-- Contador de TICs de clk

	signal 	cont_10usec 		: unsigned(7 downto 0);	-- Contador de TICs de clk
	signal 	cont_5msec 		: unsigned(7 downto 0);	-- Contador de TICs de clk

begin
 

--Proceso que determina el estado siguiente
  process (ep,to_15usec, to_10usec, to_5msec)
  begin
    case ep  is                   -- LT24_RESET_N <= '0'
        when e_init =>            -- Init_TicsCounters <= '1'
		es <= e_wait00;    -- 
 			
        when e_wait00 =>          -- LT24_RESET_N <= '0'
        	if to_15usec='1' then           -- Init_TicsCounters <= '1'
        		es <= e_wait0;
        	else
        		es <= e_wait00;
        	end if;
 			
        when e_wait0 =>                 -- TicuSec  <= '1' ; LT24_RESET_N <= '1';
        	if to_15usec='1' then
        		es <= e_wait1;  -- Init_TicsCounters <= '1'
        	else
        		es <= e_wait0;
        	end if;
        when e_wait1 =>                -- TicuSec  <= '1' ; LT24_RESET_N <= '0';
        	if to_10usec='1' then
        		es <= e_wait2;  -- Init_TicsCounters <= '1'
        	else
        		es <= e_wait1;
        	end if;
        when e_wait2 =>                -- TicmSec  <= '1' ; LT24_RESET_N <= '1';
        	if to_5msec='1' then   
        		es <= e_done;
        	else
        		es <= e_wait2;
        	end if;
       when e_done =>                  -- LT24_RESET_N <= '1';
        		es <= e_done;

    end case;
  end process;


 -- Proceso que registra el estado en cada flanco de reloj
  process (clk, reset_l)
  begin
      if reset_l = '0' then 
         ep <= e_init;
      elsif clk'event and clk='1' then 
         ep <= es ;
      end if;
  end process;


--Salidas de la UC


 -- Proceso que registra la salida de  LT24_RESET_N
  process (clk, reset_l)
  begin
      if reset_l = '0' then 
         tmp_LT24_RESET_N <= '0';
      elsif clk'event and clk='1' then 
        if (ep= e_wait0 or ep= e_wait2 or  ep= e_done ) then 
          tmp_LT24_RESET_N <= '1';
        else   
          tmp_LT24_RESET_N <= '0' ;
		  end if;
      end if;
  end process;

  LT24_RESET_N <= tmp_LT24_RESET_N;
  LT24_LCD_ON <= '1';		-- LCD ON

     Init_TicsCounters <= '1' when (ep=e_init) or (ep=e_wait00 and (to_15usec='1')) or 
                                   (ep=e_wait0 and to_15usec='1') or 
                                   (ep=e_wait1 and to_10usec='1') or 
				                       (ep=e_done)
                              else '0';

   Reset_Done <= '1' when ep=e_done  else '0';


 
   process (clk, reset_l)
   begin
      if reset_l='0' then
         divclk <= (others =>'0');
      elsif (clk'event and clk='1') then
         divclk <= divclk +1;
      end if;
   end process;

-- TicuSec Control
process (clk, reset_l)
begin
  if reset_l='0' then
    NumTicsXuSec <= (others =>'0');
    TicuSec <= '0';
  elsif (clk'event and clk='1') then
    if (Init_TicsCounters = '1') then
      NumTicsXuSec <= (others =>'0');
      TicuSec <= '0';
    elsif (NumTicsXuSec = (TICS_PER_USEC-1)) then
      NumTicsXuSec <=(others =>'0');
      TicuSec <= '1';
    else
      NumTicsXuSec <= NumTicsXuSec +1;
      TicuSec <= '0';
    end if;
  end if;
end process;

-- TicmSec Control
process (clk, reset_l)
begin
  if reset_l='0' then
    NumTicsXmSec <= (others =>'0');
    TicmSec <= '0';
  elsif (clk'event and clk='1') then
    if (Init_TicsCounters = '1') then
      NumTicsXmSec <= (others =>'0');
      TicmSec <= '0';
    elsif (NumTicsXmSec = ((MSEC/USEC)-1)) then
      NumTicsXmSec <=(others =>'0');
      TicmSec <= '1';
    elsif (TicuSec = '1') then
      NumTicsXmSec <= NumTicsXmSec +1;
      TicmSec <= '0';
    end if;
  end if;
end process;




-- to_15usec Control
process (clk, reset_l)
begin
  if reset_l='0' then
    cont_15usec <= (others =>'0');
    to_15usec <= '0';
  elsif (clk'event and clk='1') then
    if (Init_TicsCounters = '1') then
      cont_15usec <= (others =>'0');
      to_15usec <= '0';
    elsif (cont_15usec = 15) then
      cont_15usec <=(others =>'0');
      to_15usec <= '1';
    elsif (TicuSec = '1') then
      cont_15usec <= cont_15usec +1;
      to_15usec <= '0';
	 else
       to_15usec <= '0';
    end if;
  end if;
end process;

-- to_10usec Control
process (clk, reset_l)
begin
  if reset_l='0' then
    cont_10usec <= (others =>'0');
    to_10usec <= '0';
  elsif (clk'event and clk='1') then
    if (Init_TicsCounters = '1') then
      cont_10usec <= (others =>'0');
      to_10usec <= '0';
    elsif (cont_10usec = 10) then
      cont_10usec <=(others =>'0');
      to_10usec <= '1';
    elsif (TicuSec = '1') then 
      cont_10usec <= cont_10usec +1;
      to_10usec <= '0';
	 else
      to_10usec <= '0';
    end if;
  end if;
end process;


-- to_5msec Control
process (clk, reset_l)
begin
  if reset_l='0' then
    cont_5msec <= (others =>'0');
    to_5msec <= '0';
  elsif (clk'event and clk='1') then
    if (Init_TicsCounters = '1') then
      cont_5msec <= (others =>'0');
      to_5msec <= '0';
    elsif (cont_5msec = 10) then
      cont_5msec <=(others =>'0');
      to_5msec <= '1';
    elsif (TicmSec = '1') then 
      cont_5msec <= cont_5msec +1;
      to_5msec <= '0';
    end if;
  end if;
end process;



end architecture a;