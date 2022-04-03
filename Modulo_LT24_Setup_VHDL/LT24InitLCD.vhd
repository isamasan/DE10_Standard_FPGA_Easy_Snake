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



entity LT24InitLCD is
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
end entity LT24InitLCD;

architecture a of LT24InitLCD is

  component romsinc 
  port (
    clk      : in  std_logic;
    addr      : in  std_logic_vector(6 downto 0);
    datout    : out std_logic_vector(11 downto 0)
  );
  end component;
  

    signal u_romaddr   :  unsigned(6 downto 0);
    signal romaddr     :  std_logic_vector(6 downto 0);
    signal romdatout :  std_logic_vector(11 downto 0);
	 
    signal LT24_DATA_tmp :  std_logic_vector(15 downto 0);
 
   signal CMD_DATA      : std_logic;

    type t_estado2 is (e_init2, e_send_CMD_DATA, e_send_CMD_DATA2, e_wait1_sendByte, e_End_CMD_DATA );
    signal ep2, es2   : t_estado2;

    --

   type t_estado3 is (e_init3, e_read_CMD_DATA, e_read_CMD_DATA2, e_read_CMD_DATA3, e_wait_sendCMD_DATA, e_End_Send_CMD_DATA, e_End_INIT_LT24);
   signal ep3, es3       : t_estado3;

   signal cont_Tics      :  unsigned(4 downto 0);
   signal ClearTics      :  std_logic;
   signal  SendCMDData      : std_logic;
   signal  TMO_sendByte  : std_logic; 


  signal EndMemory : std_logic;                 --
  signal NextdCMD_DATA : std_logic;                 --
 

  signal EndsendCMD_DATA : std_logic;                   --
 -- signal contAddress     : unsigned(6 downto 0);	-- Contador de pos. ROM


  
begin
 

    DUT_ROM: romsinc  
    port map ( 
      clk      => clk,
      addr     => romaddr,
      datout   => romdatout
    ); 




-- --------------------------------------------------

--Unidad de Control

--------------------------------------------------

--Proceso que determina el estado siguiente envío de un dato de configuración 
  process (ep2,SendCMDData, TMO_sendByte  )
  begin
    case ep2  is                   -- 
        when e_init2 =>            -- LT24_CS_N = '1' ; LT24_RS = '1' ;LT24_WR_N = '1' ;
                 if (SendCMDData ='1' )then          
                        es2 <= e_send_CMD_DATA;
                 else
                        es2 <= e_init2;
          end if;
                        
        when e_send_CMD_DATA =>                   -- -- LT24_CS_N = '0' ; LT24_RS = CMD(0)_DATA(1) ;LT24_WR_N = '0' ; LT24_D= Data
                           es2 <= e_send_CMD_DATA2;
                                        
        when e_send_CMD_DATA2 =>                  -- -- LT24_CS_N = '1' ; LT24_WR_N = '0' ;
                           es2 <= e_wait1_sendByte;
                                        
         when e_wait1_sendByte =>    
                if TMO_sendByte='1'  then
                        es2 <= e_End_CMD_DATA;  
                else
                        es2 <= e_wait1_sendByte;
                end if;
                        
        when e_End_CMD_DATA => 
                        es2 <= e_init2;

    end case;
  end process;


 -- Proceso que registra el estado en cada flanco de reloj
   process (clk, reset_l)
   begin
      if reset_l = '0' then 
         ep2 <= e_init2;
      elsif clk'event and clk='1' then 
         ep2 <= es2 ;
      end if;
   end process;

   
   EndsendCMD_DATA <= '1' when (ep2=e_End_CMD_DATA) 
                              else '0';
   ClearTics <= '1' when (ep2 = e_send_CMD_DATA)   else '0';

 
   process (clk, reset_l)
   begin
      if reset_l='0' then
         cont_Tics <= (others =>'0');
      elsif (clk'event and clk='1') then
         if (ClearTics = '1') then
             cont_Tics <= (others =>'0');
         else
             cont_Tics <= cont_Tics +1;
         end if;
      end if;
   end process;
   
   TMO_sendByte <= '1' when (cont_Tics=x"02")   else '0';
   
   LT24_CS_N   <=  '0' when (ep2=e_End_CMD_DATA)   else '1';
   LT24_RS     <=  romdatout(8);
   LT24_WR_N   <=  '0' when (ep2=e_End_CMD_DATA)   else '1';
   
   LT24_RD_N   <=  '1' ;	--- Siempre a '1'

   LT24_DATA <= X"00" & romdatout(7 downto 0) ;
--   LT24_DATA     : out std_logic_vector(15 downto 0)

--- LCD Init  STATE MACHINE


--Proceso que recorre la memoria de los datos dato de configuración inicial del LT24
  process (ep3,LT24_Reset_Done, EndsendCMD_DATA, EndMemory  )
  begin
    case ep3  is                   -- 
        when e_init3 =>            -- ContAddress=0;
                 if (LT24_Reset_Done ='1' )then          
                        es3 <= e_read_CMD_DATA;
                 else
                        es3 <= e_init3;
          end if;
                        
        when e_read_CMD_DATA =>                   -- -- Address = romaddr_tmp
                        es3 <= e_read_CMD_DATA2;
                                        
        when e_read_CMD_DATA2 =>                  -- -- Data = ROM[Address]; 
                        es3 <= e_read_CMD_DATA3;
                                        
        when e_read_CMD_DATA3 =>                  -- -- Data = ROM[Address]; 
                        es3 <= e_wait_sendCMD_DATA;
                                        
         when e_wait_sendCMD_DATA =>    
                if EndsendCMD_DATA='1'  then
                        es3 <= e_End_Send_CMD_DATA;  
                else
                        es3 <= e_wait_sendCMD_DATA;
                end if;
                        
        when e_End_Send_CMD_DATA =>  -- romaddr_tmp++;
                if EndMemory='1'  then
                        es3 <= e_End_INIT_LT24;  
                else
                        es3 <= e_read_CMD_DATA;
                end if;

        when e_End_INIT_LT24 =>                  -- 
              es3 <= e_End_INIT_LT24;

    end case;
  end process;


 -- Proceso que registra el estado en cada flanco de reloj
  process (clk, reset_l)
  begin
      if reset_l = '0' then 
         ep3 <= e_init3;
      elsif clk'event and clk='1' then 
         ep3 <= es3 ;
      end if;
  end process;

  

  EndMemory <= '1' when (u_romaddr = ROM_NUM_DATA_VALID) 
                              else '0';

  SendCMDData <= '1' when (ep3=e_read_CMD_DATA3) 
                              else '0';
  NextdCMD_DATA  <= '1' when (ep3=e_End_Send_CMD_DATA) 
                              else '0';
  LT24_Init_Done <= '1' when (ep3=e_End_INIT_LT24) 
                              else '0';
                              
			      
  -- NextdRowCol <= '1' when (ep3=e_Test_IncRawCol) 
 --                             else '0';
                              
-- Proceso que registra el la dirección de la ROM
  process (clk, reset_l)
  begin
      if reset_l = '0' then 
         u_romaddr <= (others =>'0');
      elsif clk'event and clk='1' then 
         if (NextdCMD_DATA = '1') then
           u_romaddr <= u_romaddr +1;
         end if;
      end if;
  end process;

 romaddr <= std_logic_vector(u_romaddr);
  

 
end architecture a;