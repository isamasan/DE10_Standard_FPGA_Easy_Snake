library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Standard_MASTER is
  port(
    -- CLOCK ----------------
	 CLOCK_50 : in	std_logic;
	 
	 -- KEY ----------------
	 KEY : in std_logic_vector (3 downto 0);
	 
	 -- LEDR ----------------
    LEDR : out std_logic_vector (9 downto 0);
	 
	 -- 7-SEG ----------------
	 HEX0	: out	std_logic_vector (6 downto 0);
	 HEX1	: out	std_logic_vector (6 downto 0);

	
	 -- GPIO-LT24-UART ----------
	 -- LCD --
    LT24_LCD_ON 	: out	std_logic;
    LT24_RESET_N	: out	std_logic;
    LT24_CS_N		: out	std_logic;
    LT24_RD_N		: out	std_logic;
    LT24_RS		   : out	std_logic;
    LT24_WR_N		: out	std_logic;
    LT24_D			: out	std_logic_vector (15 downto 0);
	 
	 -- UART --
	 UART_RX : in	std_logic
  
  ); -- ***OJO*** ultimo de la lista sin ;

end;

architecture rtl of DE10_Standard_MASTER is
   -- Senales clk y reset
	signal clk, reset, reset_l : std_logic;	
	
	-- Senales para el modulo LT24Setup
   signal cs_n         : std_logic;
   signal rs           : std_logic;
   signal wr_n         : std_logic;
   signal d            : unsigned( 15 downto 0);
   signal init_done    : std_logic;
	
	-- Senales para el modulo lt24_ctrl
	signal op_cursor : std_logic;
	signal op_colour : std_logic;
	signal X 		  : unsigned (7 downto 0);
	signal Y 		  : unsigned (8 downto 0);
	signal rgb       : unsigned (15 downto 0);
	signal n_pix     : unsigned (16 downto 0);
	signal d_colour  : std_logic;
	signal d_cursor  : std_logic;
	
	-- Senales para el modulo lt24_drawing
	signal x_1 : unsigned(7 downto 0);
	signal y_1 : unsigned(8 downto 0);
	
	-- Senales para el modulo master
	signal done_pintar, done_bloque, done_borrar : std_logic;
	signal pos_ser_x, pos_blo_x                  : unsigned (7 downto 0);
   signal pos_ser_y, pos_blo_y                  : unsigned (8 downto 0);
   signal bloque, pintar, borrar                : std_logic;
	signal comando                               : unsigned(2 downto 0);
	signal encender_led									: std_logic;
	
	component LT24Setup
	  port(
        -- CLOCK and Reset_l ----------------
        clk           : in std_logic;
        reset_l       : in std_logic;
		  LT24_CS_N_Int : in std_logic;
        LT24_RS_Int   : in std_logic;
        LT24_WR_N_Int : in std_logic;
        LT24_RD_N_Int : in std_logic;
        LT24_D_Int    : in std_logic_vector(15 downto 0);

        LT24_LCD_ON    : out std_logic;
        LT24_RESET_N   : out std_logic;
        LT24_CS_N      : out std_logic;
        LT24_RS        : out std_logic;
        LT24_WR_N      : out std_logic;
        LT24_RD_N      : out std_logic;
        LT24_D         : out std_logic_vector(15 downto 0);    
		  LT24_Init_Done : out std_logic
	  );
	end component;


	component lt24_ctrl 
	  port (
		 clk, reset                    : in std_logic;
		 op_set_cursor, op_draw_colour : in std_logic;	
		 lt24_init                     : in std_logic;
		 xcol                          : in unsigned (7 downto 0);
		 yrow                          : in unsigned (8 downto 0);
		 rgb                           : in unsigned (15 downto 0);
		 num_pix                       : in unsigned (16 downto 0);
		
	 	 lt24_d                        : out unsigned (15 downto 0);
		 lt24_cs_n, lt24_wr_n, lt24_rs : out std_logic;
		 done_colour, done_cursor      : out std_logic
	  );
	end component;
	
	component lt24_drawing
	  port (
		 clk, reset               : in std_logic;
    	 pintar, borrar, bloque   : in std_logic;
		 colour_code              : in std_logic_vector (1 downto 0);
		 done_cursor, done_colour : in std_logic;
		 x_1                      : in unsigned (7 downto 0);
		 y_1                      : in unsigned (8 downto 0);

 		 op_setcursor, op_drawcolour           : out std_logic;
		 done_pintar, done_borrar, done_bloque : out std_logic;
		 xcol                                  : out unsigned (7 downto 0);
		 yrow                                  : out unsigned (8 downto 0);
		 rgb                                   : out std_logic_vector (15 downto 0);
		 num_pix                               : out unsigned (16 downto 0)
	  );
	end component;
		
	component modulo_master
	  port (
	    clk, reset 			                  : in std_logic;
	    comando                               : in unsigned (2 downto 0);
	    done_pintar, done_bloque, done_borrar : in std_logic;

	    hex0                   : out std_logic_vector (6 downto 0);
	    hex1                   : out std_logic_vector (6 downto 0);
 	    encender_led           : out std_logic;
		 x_1                    : out unsigned (7 downto 0);
		 y_1                    : out unsigned (8 downto 0);
	    bloque, pintar, borrar : out std_logic      	
	  );
	end component;
	
	component uart
	    port (
			clk,reset: in std_logic;
			uart_rx: in std_logic;

			comando: out unsigned(2 downto 0)
		);
	end component;

  begin
    -- Clock y reset
	 clk     <= CLOCK_50;
	 reset   <= comando(2);
	 reset_l <= not(comando(2));
	 
	 -- Componentes
	 C1: LT24setup port map(
	   clk            => clk,
	   reset_l        => reset_l,
      LT24_LCD_ON    => LT24_LCD_ON,
      LT24_RESET_N   => LT24_RESET_N,
      LT24_CS_N      => LT24_CS_N,
      LT24_RS        => LT24_RS,
      LT24_WR_N      => LT24_WR_N,
      LT24_RD_N      => LT24_RD_N,
      LT24_D         => LT24_D,
      LT24_CS_N_Int  => cs_n,
      LT24_RS_Int    => rs,
      LT24_WR_N_Int  => wr_n,
      LT24_RD_N_Int  => '1',  --esta en logica negativa asi que no hace nada
      LT24_D_Int     => std_logic_vector(d),
      LT24_Init_Done => init_done
	 );
		
	 C2: lt24_ctrl port map(
		 clk            => clk,
		 reset          => reset,
		 op_set_cursor  => op_cursor,
		 op_draw_colour => op_colour,
		 lt24_init      => init_done,
		 xcol           => X,
		 yrow           => Y,
		 rgb            => rgb,
		 num_pix        => n_pix,
		 lt24_d         => d,
		 lt24_cs_n      => cs_n,
		 lt24_wr_n      => wr_n,
		 lt24_rs        => rs,
		 done_colour    => d_colour,
		 done_cursor    => d_cursor
	 );
	  
	 C3: lt24_drawing port map(
		clk           => clk,
	   reset	      => reset,        
		colour_code   => "00",            
		done_cursor   => d_cursor,
		done_colour   => d_colour,
		pintar        => pintar,
		borrar        => borrar,
		bloque        => bloque,
		x_1           => x_1,
		y_1           => y_1,
		op_setcursor  => op_cursor,
		op_drawcolour => op_colour,
		xcol          => X,
		yrow          => Y,
		unsigned(rgb) => rgb,
		num_pix       => n_pix,
		done_pintar   => done_pintar,
		done_borrar   => done_borrar,
	   done_bloque   => done_bloque
	 );
		
	 C4: modulo_master port map(
		clk         => clk,
		reset       => reset,
		comando     => comando,                      
		done_pintar => done_pintar,
		done_bloque => done_bloque,
		done_borrar => done_borrar,
		x_1         => x_1,
		y_1         => y_1,
		bloque      => bloque,
		pintar      => pintar,
		borrar      => borrar,
		encender_led        => encender_led,
		hex0        => HEX0,
		hex1        => HEX1
	 );
	 
	 C5: uart port map (
		clk => clk,
		reset => reset,
		uart_rx => UART_RX,
		comando => comando
	 );
	 
	 -- Encender LEDR
	 LEDR <= (others => '1') when encender_led = '1' else (others => '0');

end rtl;
