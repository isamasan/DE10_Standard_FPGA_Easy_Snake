
-- Declaracion librerias
library ieee;
use ieee.std_logic_1164.all;	-- libreria para tipo std_logic
use ieee.numeric_std.all;	-- libreria para tipos unsigned/signed

use work.tabla_X_pkg.all;
use work.tabla_Y_pkg.all;

-- Declaracion entidad
entity modulo_master is
  port (
     -- lista de entradas y salidas del modulo: reset, clk etc
      clk, reset 			                    : in std_logic;
      comando                               : in unsigned(2 downto 0);
      done_pintar, done_bloque, done_borrar : in std_logic;

      hex0                   : out std_logic_vector (6 downto 0);
      hex1                   : out std_logic_vector (6 downto 0);
      encender_led           : out std_logic;
      x_1                    : out unsigned (7 downto 0);
      y_1                    : out unsigned (8 downto 0);
      bloque, pintar, borrar : out std_logic      	
  );
end modulo_master;

-- Declaracion de la arquitectura correspondiente a la entidad
architecture arch_modulo_master of modulo_master is

  type estado is (e0, e1, e2, e3, e4, e45, e5, e10, e11, e12, e13, e14, e15, e16, e17, e18);
  signal epres, esig                  : estado;
  signal cl_cp , incr_cp              : std_logic;
  signal puntos 		                 : unsigned(3 downto 0);
  signal perder                       : std_logic;
  signal sel_perder, sel_x, sel_y     : std_logic;
  signal sal_mux                      : std_logic_vector(9 downto 0);
  signal cl_rps_x, cl_rps_y           : std_logic;
  signal incr_rps_x, incr_rps_y       : std_logic;
  signal gen_pos_blo_x, gen_pos_blo_y : std_logic;
  signal choque, zona_choque, borde_x, borde_y     : std_logic;
  signal pos_ser_x, pos_blo_x         : unsigned(7 downto 0);
  signal pos_ser_y, pos_blo_y         : unsigned(8 downto 0);
  signal decenas, unidades            : unsigned(3 downto 0);
  signal fin_temp, cl_temp, incr_temp : std_logic;
  signal temp                         : unsigned (18 downto 0);
  signal senal_puntos, encender_led_aux : std_logic;
  
  component hex_7seg
    port (
      hex : in std_logic_vector (3 downto 0);
      dig : out std_logic_vector (6 downto 0)
    );
  end component;

  begin
  
  ----------------------------------------
  ------ UNIDAD DE CONTROL ---------------
  ----------------------------------------
  process (clk, reset)
    begin
      if reset = '1' then epres <= e0;
        elsif clk'event and clk = '1' then epres <= esig;
      end if;
  end process;
  
  -- proceso combinacional que determina el valor de esig (estado siguiente)
  process (epres, comando, done_bloque, done_pintar, done_borrar, choque, borde_x, borde_y)
    begin
      case epres is 
      -- una clausula when por cada estado posible
		  when e0 => if comando(0) = '1' then esig <= e1;
                     else esig <= e0;
                   end if;
        when e1 => esig <= e2;
        when e2 => esig <= e3;
        when e3 => if done_bloque = '1' then esig <= e4;
                     else esig <= e3;
                   end if;
        when e4 => if (comando(1) = '1' and zona_choque = '1') then esig <= e16;
							elsif (comando(1) = '1' and zona_choque = '0') then esig <= e14;
						   else esig <= e45;
                   end if;
		  when e45 => if fin_temp = '1' then esig <= e5;
		      else esig <= e45;
                    end if;
        when e5 => if (done_pintar = '1' and choque = '0' and borde_x = '0') then esig <= e10;
                     elsif (done_pintar = '1' and choque = '0' and borde_x = '1' and borde_y = '0') then esig <= e12; 
                     elsif (done_pintar = '1' and choque = '0' and borde_x = '1' and borde_y = '1') then esig <= e11;
                     elsif (done_pintar = '1' and choque = '1') then esig <= e14;
		     else esig <= e5;
                   end if;
        when e10 => esig <=  e4;
        when e11 => esig <= e13;
        when e12 => esig <= e4;
        when e13 => if (done_borrar = '1') then esig <= e2;
                      else esig <= e13;
                    end if;
        when e14 => esig <= e15;
		  when e15 => esig <= e15;
        when e16 => esig <= e17;
        when e17 => if comando(0) = '1' then esig <= e18;
                      else esig <= e17;
                    end if;
        when e18 => if done_borrar = '1' then esig <= e1;
                      else esig <= e18;
                    end if;
      end case;
    end process;

  -- Senales de control
  cl_cp 	       <= '1' when (epres = e0 or epres = e14) else '0';
  cl_rps_x 	    <= '1' when (epres = e1 or epres = e11 or epres = e12) else '0';
  cl_rps_y 	    <= '1' when (epres = e1 or epres = e11) else '0';
  gen_pos_blo_x <= '1' when epres = e2 else '0';
  gen_pos_blo_y <= '1' when epres = e2 else '0';
  sel_x         <= '1' when epres = e3 else '0';
  sel_y         <= '1' when epres = e3 else '0';
  bloque 	    <= '1' when epres = e3 else '0';
  cl_temp       <= '1' when epres = e4 else '0';
  incr_temp     <= '1' when epres = e45 else '0';
  pintar 	    <= '1' when epres = e5 else '0';
  incr_cp 	    <= '1' when epres = e16 else '0';
  sel_perder    <= '1' when epres = e15 else '0';
  incr_rps_x 	 <= '1' when epres = e10 else '0';
  incr_rps_y 	 <= '1' when epres = e12 else '0';
  borrar 	    <= '1' when (epres = e13 or epres = e0 or epres = e18) else '0';
  encender_led_aux <= '1' when epres = e17 else '0';

  ----------------------------------------
  ------ UNIDAD DE PROCESO ---------------
  ----------------------------------------

  -- Contador de puntos
  process (clk)
    begin
      if clk'event and clk = '1' then
        if (cl_cp = '1' or senal_puntos = '1') then puntos <= (others => '0');
			elsif incr_cp = '1' then puntos <= puntos + 1;
        end if;
      end if;
  end process;
  
  process (clk)
    begin
	   if clk'event and clk = '1' then
		  if sel_perder = '1' then decenas <= (others => '1'); unidades <= (others => '1');
		    elsif cl_cp = '1' then decenas <= (others => '0'); unidades <= (others => '0');
		    elsif senal_puntos = '1' then decenas <= decenas + 1;
			 else decenas <= decenas; unidades <= puntos;
		  end if;
		end if;
  end process;
  
  senal_puntos <= '1' when puntos = "1010" else '0';

  -- Codificador de hexadecimal a 7 segmentos
  c1: hex_7seg port map(hex => std_logic_vector(unidades), dig => hex0);

  c2: hex_7seg port map(hex => std_logic_vector(decenas), dig => hex1);
  

  -- Registro de posicion X de serpiente
  process (clk)
    begin
      if clk'event and clk = '1' then
        if cl_rps_x = '1' then pos_ser_x <= (others => '0');
          elsif incr_rps_x = '1' then pos_ser_x <= pos_ser_x + 1;
        end if;
      end if;
  end process;

  -- Registro de posicion Y de serpiente
  process (clk)
    begin
      if clk'event and clk = '1' then
        if cl_rps_y = '1' then pos_ser_y <= (others => '0');
          elsif incr_rps_y = '1' then pos_ser_y <= pos_ser_y + 16;
        end if;
      end if;
  end process;

  -- Registro de posicion X de bloque
  process (clk)
    begin
      if clk'event and clk = '1' then
        if gen_pos_blo_x = '1' then pos_blo_x <= t2(to_integer(puntos));
        end if;	
      end if;
  end process;

  -- Registro de posicion Y de bloque
  process (clk)
    begin
      if clk'event and clk = '1' then
        if gen_pos_blo_y = '1' then pos_blo_y <= t1(to_integer(puntos));
        end if;
      end if;
  end process;

  -- Multiplexores de senales de posicion
  x_1 <= pos_blo_x when sel_x = '1' else pos_ser_x;
  y_1 <= pos_blo_y when sel_y = '1' else pos_ser_y;  

  -- Temporizador
  process (clk)
    begin
      if clk'event and clk = '1' then
        if cl_temp = '1' then temp <= (others => '0');
 	  elsif incr_temp = '1' then temp <= temp + 1;
        end if;
      end if;
  end process;
  fin_temp <= '1' when temp = "1111111111111111111" else '0';
  
  -- Senales 'choque', 'borde_x' y ' borde_y'
  zona_choque  <= '1' when (pos_ser_x > pos_blo_x - 16 and pos_ser_y = pos_blo_y) else '0';
  choque  <= '1' when (pos_ser_x = pos_blo_x and pos_ser_y = pos_blo_y) else '0';
  borde_x <= '1' when pos_ser_x = 240 else '0';
  borde_y <= '1' when pos_ser_y = 320 else '0'; 
  
  -- Salida encender_led
  encender_led <= encender_led_aux;
 
end arch_modulo_master;

