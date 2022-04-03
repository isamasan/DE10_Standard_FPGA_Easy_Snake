
-- Plantilla tipo para la descripcion de un modulo diseñado segun la 
-- metodologia vista en clase: UC+UP

-- Declaracion librerias
library ieee;
use ieee.std_logic_1164.all;	-- libreria para tipo std_logic
use ieee.numeric_std.all;	-- libreria para tipos unsigned/signed

-- Declaracion entidad
entity LT24_Drawing is
  port (
     -- lista de entradas y salidas del modulo: reset, clk etc
	clk,reset: in std_logic;
    	pintar,borrar,bloque: in std_logic;
	colour_code: in std_logic_vector (1 downto 0);
	done_cursor,done_colour: in std_logic;
	x_1: in unsigned(7 downto 0);
	y_1: in unsigned(8 downto 0);

	op_setcursor,op_drawcolour: out std_logic;
	done_pintar,done_borrar,done_bloque: out std_logic;
	xcol : out unsigned(7 downto 0);
	yrow : out unsigned(8 downto 0);
	rgb : out std_logic_vector(15 downto 0);
	num_pix : out unsigned(16 downto 0)
	 
  );
end LT24_Drawing;

-- Declaracion de la arquitectura correspondiente a la entidad
architecture arch_LT24_Drawing of LT24_Drawing is

  -- declaracion de tipos y señales internas del sistema
  --	tipo nuevo para el estado de la UC y dos señales de ese tipo
  type estado is (e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11,e12);
  signal epres,esig: estado;

  signal r_pintar, r_bloque: std_logic;
  signal ld_pin_blo: std_logic;
  
  signal ld_x_y: std_logic;
  
  signal ld_pos_y, incr_y: std_logic;

  signal sel_cont, sel_num_pix: std_logic;

  signal r_x: unsigned(7 downto 0);
  signal r_y: unsigned(8 downto 0);
  signal aux_yrow: unsigned(8 downto 0);
  signal r_cont: unsigned(8 downto 0);

  signal sel_rgb: std_logic_vector(1 downto 0);
  signal ld_rgb: std_logic;
  signal r_rgb: std_logic_vector(15 downto 0);

    
  begin -- comienzo de nombre_arquitectura
  
  ----------------------------------------
  ------ UNIDAD DE CONTROL ---------------
  ----------------------------------------

  -- proceso sincrono que actualiza el estado en flanco de reloj. Reset asincrono.
  process (clk,reset)
    begin
      if reset='1' then epres<=e1;
        elsif clk'event and clk='1' then epres<=esig;
      end if;
  end process; 
  
  -- proceso combinacional que determina el valor de esig (estado siguiente)
  process (epres, pintar, bloque, borrar, done_cursor, done_colour, R_pintar, R_bloque, aux_yrow)
    begin
      case epres is 
      -- una clausula when por cada estado posible
        when e1 => if pintar='1' then esig<=e2;
			elsif bloque='1' then esig<=e3;
			elsif borrar='1' then esig<=e9;
			else esig<=e1;
		end if;
	when e2 => esig <= e4;
	when e3 => esig <= e4;
	when e4 => if done_cursor='1' then esig<=e5;
			else esig<=e4;
		end if;
	when e5 => if done_colour='0' then esig<=e5;
			elsif aux_yrow/=r_y+8 then esig<=e6;
			elsif R_pintar='1' then esig<=e7;
			else esig<=e8;
		end if;
	when e6 => esig <= e4;
	when e7 => esig <= e1;
	when e8 => esig <= e1;
	when e9 => esig <= e10;
	when e10 => if done_cursor='1' then esig <= e11;
			else esig <= e10;
		end if;
	when e11 => if done_colour='1' then esig <= e12;
			else esig <= e11;
		end if;
	when e12 => esig <= e1;
      
      end case;
    end process;

  -- una asignacion condicional para cada señal de control que genera la UC
  ld_pos_y <='1' when ((epres = e2) or (epres = e3) or (epres = e9)) else '0'; -- si es en logica positiva
  ld_pin_blo <='1' when epres=e1 else '0'; 
  sel_cont <='1' when ((epres = e1) or (epres = e2) or (epres = e3) or (epres = e4) or (epres = e5) or (epres = e6) or (epres = e7) or (epres = e8)) else '0';
  op_setcursor <= '1' when ((epres = e4) or (epres = e10)) else '0';
  op_drawcolour <= '1' when ((epres = e5) or (epres = e11)) else '0';
  incr_y <= '1' when epres=e6 else '0';
  done_pintar <='1' when epres=e7 else '0';
  done_bloque <='1' when epres=e8 else '0';
  done_borrar <='1' when epres=e12 else '0';
  sel_num_pix <='1' when epres=e11 else '0';
  ld_x_y <='1' when epres = e1 else '0'; 

  sel_rgb <= "10" when epres=e2 else
		"01" when epres=e3 else
		"00";

  ld_rgb <= '1' when ((epres = e2) or (epres = e3) or (epres = e9)) else '0';


  ----------------------------------------
  ------ UNIDAD DE PROCESO ---------------
  ----------------------------------------

  -- codigo apropiado para cada uno de los componentes de la UP

  -- registro R_X
  process (clk)	
    begin
      if clk'event and clk='1' then 
		if ld_x_y='1' then 
			r_x<=x_1;	
			r_y<=y_1;
		end if;
      end if;
  end process;

  --MUX
  num_pix <= "00000000000001000" when sel_num_pix = '0' else "10010110000000000";

  r_cont <= r_y when sel_cont='1' else "000000000";

  --Señal RCOL
  xcol <= r_x when sel_cont='1' else "00000000";
 
  --Señal YROW
  process(clk)
    begin
	if clk'event and clk='1' then
		if ld_pos_y='1' then aux_yrow<= r_cont;
		elsif incr_y='1' then aux_yrow<=aux_yrow+1;
		end if;
	end if;
  end process;
  yrow <= aux_yrow;
  

  --Registros pintar y bloque
    process (clk)	
    begin
      if clk'event and clk='1' then 
		if ld_pin_blo='1' then 
			r_pintar<=pintar;	
			r_bloque<=bloque;
		end if;
      end if;
  end process;


  --RGB

  -- registro RGB
  process (clk)	
    begin
      if clk'event and clk='1' then 
		if ld_rgb='1' then rgb<=r_rgb;	
		end if;
      end if;
  end process;

 -- Decodificador
  r_rgb <= (4 downto 0 => '1', others => '0') when sel_rgb="10" else
	 (10 downto 5 => '1', others => '0') when sel_rgb="01" else
	 (15 downto 11 => '1', others => '0') when sel_rgb="00" else
	  X"0000";
 
  

end arch_LT24_Drawing;

