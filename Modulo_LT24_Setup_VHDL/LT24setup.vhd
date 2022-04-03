------------------------------------------------------
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
--- Version: V0.0  Basic design with internal ROM
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.romData_pkg.all;

entity LT24Setup is
 port(
      -- CLOCK and Reset_l ----------------
      clk            : in      std_logic;
      reset_l        : in      std_logic;

      LT24_LCD_ON      : out std_logic;
      LT24_RESET_N     : out std_logic;
      LT24_CS_N        : out std_logic;
      LT24_RS          : out std_logic;
      LT24_WR_N        : out std_logic;
      LT24_RD_N        : out std_logic;
      LT24_D           : out std_logic_vector(15 downto 0);

      LT24_CS_N_Int        : in std_logic;
      LT24_RS_Int          : in std_logic;
      LT24_WR_N_Int        : in std_logic;
      LT24_RD_N_Int        : in std_logic;
      LT24_D_Int           : in std_logic_vector(15 downto 0);
      
      LT24_Init_Done       : out std_logic
 );
end;

architecture rtl_0 of LT24Setup is 

  component romsinc 
  port (
    clk         : in  std_logic;
    addr        : in  std_logic_vector(6 downto 0);
    datout      : out std_logic_vector(11 downto 0)
  );
  end component;


   component LT24InitReset is
   port (
       clk              : in  std_logic;
       reset_l   :in  std_logic;

       Reset_Done       : out std_logic;
    
       LT24_RESET_N     : out std_logic;
       LT24_LCD_ON      : out std_logic

   );
   end  component;

    component LT24InitLCD is
    port (
       clk           : in  std_logic;
       reset_l       : in  std_logic;

       LT24_Reset_Done    : in std_logic;
    
       LT24_Init_Done     : out std_logic;
       
       LT24_CS_N     : out std_logic;
       LT24_RS       : out std_logic;
       LT24_WR_N     : out std_logic;
       LT24_RD_N     : out std_logic;
       LT24_DATA     : out std_logic_vector(15 downto 0)
   );
   end component;
  
  
--------------------------------------------------
---------------------------Internal signals----------------------------

         
        signal  LT24_Reset_Done  : std_logic;              -- Inic Tic Counters
        signal  tmp_LT24_RESET_N : std_logic;              -- tmp_LT24_RESET_N

        signal  LT24_Init_Done_Tmp: std_logic;              -- tmp_LT24_RESET_N


        signal Set_LT24_CS_N     :  std_logic;
        signal Set_LT24_RS       :  std_logic;
        signal Set_T24_WR_N      :  std_logic;
        signal Set_LT24_RD_N     :  std_logic;
        signal Set_LT24_D        :  std_logic_vector(15 downto 0);
        
begin 
        

  DUT_RESET:LT24InitReset 
  port map ( 
      clk          => clk,
      reset_l      => reset_l,
      Reset_Done         => LT24_Reset_Done,
    
      LT24_RESET_N      => tmp_LT24_RESET_N,
      LT24_LCD_ON       => LT24_LCD_ON

  );

      LT24_RESET_N  <= tmp_LT24_RESET_N;


  DUT_InitLCD:LT24InitLCD 
    port map ( 
      clk          => clk,
      reset_l      => reset_l,
      LT24_Reset_Done    => LT24_Reset_Done,
                
       LT24_Init_Done  => LT24_Init_Done_Tmp,
       
       LT24_CS_N   => Set_LT24_CS_N,
       LT24_RS     => Set_LT24_RS,
       LT24_WR_N   => Set_T24_WR_N,
       LT24_RD_N   => Set_LT24_RD_N,
       LT24_DATA   => Set_LT24_D
   );

	LT24_Init_Done <= LT24_Init_Done_Tmp;

 -- Proceso que registra las señales cada en cada flanco de reloj si  LT24_Init_Done está activado
  process (clk, reset_l)
  begin
      if reset_l = '0' then 
         LT24_CS_N <= '0';
         LT24_RS     <=  '1';
         LT24_WR_N   <=  '1';
         LT24_RD_N   <=  '1';
         LT24_D   <=  (others =>'0');
      elsif clk'event and clk='1' then 
         if LT24_Init_Done_Tmp = '0' then
             LT24_CS_N   <=  Set_LT24_CS_N;
             LT24_RS     <=  Set_LT24_RS;
             LT24_WR_N   <=  Set_T24_WR_N;
             LT24_RD_N   <=  Set_LT24_RD_N;
             LT24_D   <=  Set_LT24_D;
         else
             LT24_CS_N   <=  LT24_CS_N_Int;
             LT24_RS     <=  LT24_RS_Int;
             LT24_WR_N   <=  LT24_WR_N_Int;
             LT24_RD_N   <=  Set_LT24_RD_N;
             LT24_D   <=  LT24_D_Int;
        end if;
      end if;
  end process;



--------------------------------------------------
END rtl_0;