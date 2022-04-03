-- Plantilla tipo para la descripcion de un modulo dise�ado segun la 
-- metodologia vista en clase: UC+UP

-- Declaracion librerias
library ieee;
use ieee.std_logic_1164.all;	-- libreria para tipo std_logic
use ieee.numeric_std.all;	-- libreria para tipos unsigned/signed

-- Declaracion entidad
entity lt24_ctrl is
  port (
     -- lista de entradas y salidas del modulo: reset, clk etc
	clk, reset: in std_logic;
    	op_set_cursor, op_draw_colour : in std_logic;	
	lt24_init : in std_logic;
	xcol : in unsigned(7 downto 0);
	yrow : in unsigned(8 downto 0);
	rgb : in unsigned(15 downto 0);
	num_pix : in unsigned(16 downto 0);
	lt24_d : out unsigned(15 downto 0);
	lt24_cs_n, lt24_wr_n, lt24_rs : out std_logic;
	done_colour, done_cursor : out std_logic
  );
end lt24_ctrl;

-- Declaracion de la arquitectura correspondiente a la entidad
architecture arch_lt24_ctrl of lt24_ctrl is

  -- declaracion de tipos y se�ales internas del sistema
  --	tipo nuevo para el estado de la UC y dos se�ales de ese tipo
  type estado is (e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14);
  signal epres, esig: estado;
  signal ld_rx, ld_ry, cl_cont, k_rs, j_rs : std_logic;
  signal ld_rgb, ld_num_pix, ld_cont, dcr_num_pix : std_logic;
  signal incr_cont, en_mux : std_logic;
  signal sel : unsigned(2 downto 0);
  signal fin_pix : std_logic;
  signal rx, ry_bit8, ry_bits70, r_rgb : unsigned(15 downto 0);
  signal r_num_pix : unsigned(16 downto 0);
  signal lt24_cs_n_aux, lt24_wr_n_aux, lt24_rs_n_aux, done_cursor_aux, done_colour_aux : std_logic;
  
  begin
  
  ----------------------------------------
  ------ UNIDAD DE CONTROL ---------------
  ----------------------------------------

  -- proceso sincrono que actualiza el estado en flanco de reloj. Reset asincrono.
  process (clk, reset)
    begin
      if reset = '1' then epres <= e0;
        elsif clk'event and clk='1' then epres<=esig;
      end if;
  end process;
  
  -- proceso combinacional que determina el valor de esig (estado siguiente)
  process (epres, op_set_cursor, op_draw_colour, lt24_init, sel, fin_pix)
    begin
      case epres is 
      -- una clausula when por cada estado posible
        when e0 => if lt24_init = '0' then esig <= e0;
		     else esig <= e1;
		   end if;
        when e1 => if op_set_cursor = '1' then esig <= e2;
		     elsif op_draw_colour = '1' then esig <= e3;
		     else esig <= e1;
		   end if;
	when e2 => esig <= e4;
	when e4 => esig <= e5;
	when e5 => esig <= e6;
	when e6 => esig <= e7;
	when e7 => if sel = "101" then esig <= e8; 
		     else esig <= e4;
		   end if;
	when e8 => esig <= e1;
	
	when e3 => esig <= e9;
	when e9 => esig <= e10;
	when e10 => esig <= e11;
	when e11 => if sel = "110" then esig <= e12;
		      elsif fin_pix = '1' then esig <= e14;
		      else esig <= e13;
		    end if;
	when e12 => esig <= e9;
	when e13 => esig <= e9;
	when e14 => esig <= e1;
      end case;
  end process;

  -- una asignacion condicional para cada se�al de control que genera la UC
  ld_rx <= '1' when epres = e2 else '0';
  ld_ry <= '1' when epres = e2 else '0';
  cl_cont <= '1' when epres = e2 else '0';
  k_rs <= '1' when (epres = e2 or (epres = e7 and sel = "010") or (epres = e3)) else '0';
  j_rs <= '1' when (epres = e12 or (epres = e7 and sel /= "010" and sel /= "101")) else '0';
  ld_rgb <= '1' when epres = e3 else '0';
  ld_num_pix <= '1' when epres = e3 else '0';
  ld_cont <= '1' when epres = e3 else '0';
  lt24_cs_n <= '0' when (epres = e4 or epres = e9) else '1';
  lt24_wr_n <= '0' when (epres = e4 or epres = e9) else '1';
  incr_cont <= '1' when (epres = e7 or epres = e12) else '0';
  done_cursor <= '1' when epres = e8 else '0';
  dcr_num_pix <= '1' when epres = e13 else '0';
  done_colour <= '1' when epres = e14 else '0';
  en_mux <= '1' when ((epres = e4) or (epres = e5) or (epres = e6) or (epres = e7) or (epres = e9) or (epres = e10) or (epres = e11) or (epres = e12) or (epres = e13)) else '0';
  
  ----------------------------------------
  ------ UNIDAD DE PROCESO ---------------
  ----------------------------------------

  -- Registro RX
  process (clk)
    begin
      if (clk'event and clk = '1') then
        if ld_rx = '1' then rx <= X"00"&xcol;
        end if;
      end if;
  end process;

  -- Registro RY
  process (clk)
    begin
      if (clk'event and clk = '1') then
        if ld_ry = '1' then ry_bit8 <= (0 => yrow(8), others => '0'); ry_bits70 <= X"00"&yrow(7 downto 0);	--?�?�??�?�??�
        end if;
      end if;
  end process;

  -- Registro RGB
  process (clk)
    begin
      if (clk'event and clk = '1') then
        if ld_rgb = '1' then r_rgb <= rgb;
	end if;
      end if;
  end process;

  -- Registro Num_Pix
  process (clk)
    begin
      if (clk'event and clk = '1') then
        if ld_num_pix = '1' then r_num_pix <= num_pix;
          elsif dcr_num_pix = '1' then r_num_pix <= r_num_pix - 1;
        end if;
      end if;
  end process;
  fin_pix <= '1' when r_num_pix = 0 else '0';
  
  -- Flip-flop JK de LT24_RS
  process (clk)
    begin
      if (clk'event and clk = '1') then
        if j_rs = '1' then lt24_rs <= '1';
          elsif k_rs = '1' then lt24_rs <= '0';
        end if;
      end if;
  end process;

  -- Contador
  process (clk, cl_cont)	--no hace falta meter cl_cont en la lista de sensibilidad
    begin
      if cl_cont = '1' then sel <= "000";	--no esta sincronizado
        elsif (clk'event and clk = '1') then
          if ld_cont = '1' then sel <= "110";
            elsif incr_cont = '1' then sel <= sel + 1;
          end if;
      end if;
  end process;

 -- Multiplexador
  process (clk, rx, ry_bit8, ry_bits70, r_rgb, en_mux, sel)
     begin
       if en_mux='1' then
         case sel is
           when "000" => lt24_d <= x"002A";
           when "001" => lt24_d <= x"0000";		
           when "010" => lt24_d <= rx;
           when "011" => lt24_d <= x"002B";	
           when "100" => lt24_d <= ry_bit8;	
           when "101" => lt24_d <= ry_bits70;
           when "110" => lt24_d <= x"002C";
           when others => lt24_d <= r_rgb;
         end case;
			else lt24_d <= (others => '0');
       end if;
 end process;

 -- en e1 o e0 resetear variables??
			--rx,ry, para cuando no tienen ningun valor

end arch_lt24_ctrl;

