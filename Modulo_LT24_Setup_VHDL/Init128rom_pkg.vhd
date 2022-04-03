LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE romData_pkg IS

--   type rom_type is array (0 to (2**8)-1) of std_logic_vector(16 downto 0);
	TYPE rom_type IS ARRAY (0 TO (2**7)-1) OF std_logic_vector(11 DOWNTO 0);
	CONSTANT Init128romData : rom_type;
	CONSTANT ROM_NUM_DATA_VALID : integer;

END romData_pkg;

PACKAGE BODY romData_pkg IS
	CONSTANT  ROM_NUM_DATA_VALID : integer := 95;
	CONSTANT Init128romData : rom_type := (

	x"011", -- Exit Sleep
	x"0CF", -- Power control B
		x"100" ,
		x"181" ,
		x"1c0" ,
	x"0ED" , -- Power on sequence control
		x"164" ,
		x"103" ,
		x"112" ,
		x"181" ,
	x"0E8" , -- Driver timing control A
		x"185" ,
		x"101" ,
		x"178" ,
	x"0CB" , -- Power control A
		x"139" ,
		x"12C" ,
		x"100" ,
		x"134" ,
		x"102" ,
	x"0F7" , -- Pump ratio control
		x"120" ,
	x"0EA" , -- Driver timing control B
		x"100" ,
		x"100" ,
	x"0B1" , -- Frame Rate Control
		x"100" ,
		x"11b" ,
	x"0B6" , --  Display Function Control
		x"10A" ,
		x"1A2" ,
	x"0C0" ,    -- Power control
		x"105" ,   -- VRH[5:0]
	x"0C1" ,    -- Power control
		x"111" ,   -- SAP[2:0];BT[3:0]
	x"0C5" ,    -- VCM control
		x"145" ,       -- 3F
		x"145" ,       -- 3C
	 x"0C7" ,    -- VCM control2
		 x"1a2" ,
	x"036" ,    --  Memory Access Control
		x"108" ,-- 48
	x"0F2" ,    --  3Gamma Function Disable
		x"100" ,
	x"026" ,    -- Gamma curve selected
		x"101" ,
	x"0E0" ,    -- Set Gamma Positive Gamma Correction
		x"10F" ,
		x"126" ,
		x"124" ,
		x"10b" ,
		x"10E" ,
		x"108" ,
		x"14b" ,
		x"1a8" ,
		x"13b" ,
		x"10a" ,
		x"114" ,
		x"106" ,
		x"110" ,
		x"109" ,
		x"100" ,
	x"0E1" ,    -- Set Gamma Negative Gamma Correction
		x"100" , 
		x"11c" , 
		x"120" , 
		x"104" , 
		x"110" , 
		x"108" , 
		x"134" , 
		x"147" , 
		x"144" , 
		x"105" , 
		x"10b" , 
		x"109" , 
		x"12f" , 
		x"136" , 
		x"10f" , 
	x"02A" ,    --  Column Address Set
		x"100" , 
		x"100" , 
		x"100" , 
		x"1ef" , 
	 x"02B" ,   --  Page Address Set
		x"100" , 
		x"100" , 
		x"101" , 
		x"13f" , 
	x"03A" ,   --  COLMOD: Pixel Format Set (RGB 5-6-5 bits)
		x"155" , 
	x"0f6" ,    --  Interface Control
		x"101" , 
		x"130" , 
		x"100" , 
	x"029" ,   --  Display ON
	x"02c" ,   --  Memory Write
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000" ,   --  Dummy data 
	x"000"    --  Dummy data 
);

END PACKAGE BODY romData_pkg;