-- Declaracion librerias
library ieee;
use ieee.std_logic_1164.all;	-- libreria para tipo std_logic
use ieee.numeric_std.all;	-- libreria para tipos unsigned/signed

-- Declaracion entidad
entity UART is
  port (
     -- lista de entradas y salidas del modulo: reset, clk etc
	clk,reset: in std_logic;

   uart_rx: in std_logic;

	comando: out unsigned(2 downto 0)
  );
end UART;

-- Declaracion de la arquitectura correspondiente a la entidad
architecture arch_UART of UART is
  type estado is (e0,e1,e2,e3,e4,e5,e6,e7,e8,e9);
  signal epres,esig: estado;

  signal tiempo_bit, tiempo_medio_bit : std_logic;
  signal c3: unsigned(2 downto 0);
  signal incr_temp, cl_temp, despl_r, incr_c3, cl_r, ld_dato, cl_c3: std_logic;
  signal temp, valor_1_bit, valor_medio_bit: unsigned(12 downto 0);
  signal dato : std_logic_vector (7 downto 0);
  signal dato_decodificado: unsigned (2 downto 0); 
    
  begin -- comienzo de nombre_arquitectura
  
  ----------------------------------------
  ------ UNIDAD DE CONTROL ---------------
  ----------------------------------------

  -- proceso sincrono que actualiza el estado en flanco de reloj. Reset asincrono.
  process (clk,reset)
    begin
      if reset='1' then epres<=e0;
        elsif clk'event and clk='1' then epres<=esig;
      end if;
  end process; 
  
  -- proceso combinacional que determina el valor de esig (estado siguiente)
  process (epres, uart_rx, tiempo_bit, tiempo_medio_bit, c3)
    begin
      case epres is 
      -- una clausula when por cada estado posible
        when e0 => if uart_rx='0' then esig<=e1;
			else esig<=e0;
		end if;
	when e1 => if tiempo_bit='1' then esig<=e2;
		elsif (tiempo_bit='0' and uart_rx='0') then esig<=e1;
		else esig<=e0;
		end if;
	when e2 => esig<=e3;
	when e3 => if tiempo_medio_bit='0' then esig<=e3;
		else esig<=e4;
		end if;
	when e4 => esig<=e5;
	when e5 =>
		if (tiempo_medio_bit='1' and c3/="111") then esig<=e6;
		elsif (tiempo_medio_bit='1' and c3="111" and uart_rx='1') then esig<=e7;
		elsif (tiempo_medio_bit='1' and c3="111" and uart_rx='0') then esig<=e0;
		else esig<=e5;
		end if;
	when e6 => esig<=e2;
	when e7 => if tiempo_bit='1' then esig<=e9;
		elsif (tiempo_bit='0' and uart_rx='1') then esig<=e7;
		else esig<=e8;
		end if;
	when e8 => esig<=e0;
	when e9 => esig<=e0;	
      end case;
    end process;

  -- una asignacion condicional para cada se?al de control que genera la UC
  incr_temp <='1' when ((epres = e1) or (epres = e3) or (epres = e5) or (epres = e7)) else '0'; 
  cl_temp <='1' when (epres=e0 or epres=e2 or epres=e4) else '0';
  despl_r <='1' when epres=e4 else '0';
  incr_c3 <='1' when epres=e6 else '0';
  cl_r <='1' when epres=e8 else '0';
  ld_dato <='1' when epres=e9 else '0';
  cl_c3 <='1' when epres=e0 else '0';


  ----------------------------------------
  ------ UNIDAD DE PROCESO ---------------
  ----------------------------------------

  -- Contador de 3 bit
  process (clk)	
    begin
     if clk'event and clk='1' then 
		if cl_c3='1' then c3<="000";
		elsif incr_c3='1' then c3<=c3+1;
		end if;
     end if;
  end process;


  --Temporizador
  process (clk)
   begin
	  if clk'event and clk='1' then 
		if cl_temp='1' then temp<=(others => '0');
		elsif incr_temp='1' then temp<=temp+1;
		end if;
	end if;
  end process;

  --Comparador
  valor_1_bit<=	"1010001011000";	--5208
  valor_medio_bit<="0101000101100";	--2604

  tiempo_bit<='1' when temp=valor_1_bit else '0';
  tiempo_medio_bit<='1' when temp=valor_medio_bit else '0';



  --Registro de desplazamiento
  process (clk)
    begin
	  if clk'event and clk='1' then 
		if despl_r='1' then 
			dato(6 downto 0) <= dato(7 downto 1);
			dato(7)<=uart_rx;
		  elsif cl_r='1' then dato<="00000000";
		end if;
	end if;
  end process;


  -- Decodificador uart
  dato_decodificado <= "001" when (dato = "01001010" or dato = "01101010") else -- J, j (jugar)
			              "010" when (dato = "01010000" or dato = "01110000") else -- P, p (parar)
			              "100" when (dato = "01010010" or dato = "01110010") else -- R, r (reset) 
							  "000";


  --Registro de comando
  process (clk, reset)
   begin
	if reset='1' then comando <= "000";
		elsif clk'event and clk='1' then 
			if ld_dato='1' then comando <= dato_decodificado;
			end if;
	end if;
  end process;
		

end arch_UART;

