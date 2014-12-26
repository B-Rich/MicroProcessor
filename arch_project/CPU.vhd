library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CPU is
  port(
  CLK,Rst :in std_logic);
end CPU;    
architecture Arch of CPU is

component ram is
port (
clk : in std_logic;
R,W : in std_logic;
address : in std_logic_vector(15 downto 0);
datain : in std_logic_vector(15 downto 0);
dataout : out std_logic_vector(15 downto 0);
MFC:out std_logic);
end component;


component my_nreg is
Generic ( n : integer := 16);
port( Clk,Rst,ENA : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0));
end component;

component ALSU is  
			port (a,b:in std_logic_vector (15 downto 0);
		cin: in std_logic;
		S : in std_logic_vector (3 downto 0);
		F : out std_logic_vector (15 downto 0);
		Neg,OV,Zero,cout: out std_logic);    
end component;

component tri_state_buffer is
	Generic ( n : integer := 16);
    Port ( EN   : in  STD_LOGIC;    -- single buffer enable
           Input  : in  STD_LOGIC_VECTOR (n-1 downto 0);
           Output : out STD_LOGIC_VECTOR (n-1 downto 0));
end component;

component Control_Unit is
  port(
    IR:in std_logic_vector(15 downto 0);
    CLK :in std_logic;
	Rst :in std_logic;
    R0in,R1in,R2in,R3in,
    R0out,R1out,R2out,R3out,
    PCout,MDRout,Zout,RSRCout,RDSTout,SOURCEout,DESTINout,TEMPout, --F1
    PCin,IRin,Zin,RSRCin,RDSTin,                                   --F2
    MARin,MDRin,TEMPin,                                            --F3
    Yin,SOURCEin,DESTINin,                                         --F4
    RD,WR,                                                    --F6
    CLEARY,                                                        --F7
    CARRYin,                                                       --F8
    FLAGS_E                                                           --F9   
    :out std_logic;
    ALSU_SIGNALS:out std_logic_vector(3 downto 0)                  --F5
  );
end component;

signal IR:std_logic_vector(15 downto 0);
 signal R0in,R1in,R2in,R3in,
		R0out,R1out,R2out,R3out,
		PCout,MDRout,Zout,RSRCout,RDSTout,SOURCEout,DESTINout,TEMPout, 
		PCin,IRin,Zin,RSRCin,RDSTin,                                   
		MARin,MDRin,TEMPin,                                            
		Yin,SOURCEin,DESTINin,                                         
		RD,WR,                                                   
		CLEARY,                                                        
		CARRYin,                                                       
		FLAGS_E                                                           
		:std_logic;
signal  ALSU_SIGNALS:std_logic_vector(3 downto 0);	
signal mdrINPUT,ramOUT,buss,AfromY,Z,ramIN,ADD:std_logic_vector(15 downto 0);
signal R00out,R11out,R22out,R33out,Srcout,Destout,Tout:std_logic_vector(15 downto 0);
signal Flags:std_logic_vector(3 downto 0); 
signal mdrENABLE,MFC,selection,CLRY:std_logic;
--------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%-------------------------------
begin
  CLRY<=CLEARY or Rst;
 mdrINPUT<=ramOUT when MFC='1'
else buss when MDRin='1';
mdrENABLE<=MDRin or MFC;
CU:Control_Unit port map(
		IR,CLK,Rst,R0in,R1in,R2in,R3in,
		R0out,R1out,R2out,R3out,
		PCout,MDRout,Zout,RSRCout,RDSTout,SOURCEout,DESTINout,TEMPout, 
		PCin,IRin,Zin,RSRCin,RDSTin,                                   
		MARin,MDRin,TEMPin,                                            
		Yin,SOURCEin,DESTINin,                                         
		RD,WR,                                                   
		CLEARY,                                                        
		CARRYin,                                                       
		FLAGS_E,      
		ALSU_SIGNALS);
---------------------------------------REGISTERS------------------------------------
TriR0:tri_state_buffer generic map(16) port map(R0out,R00out,buss);
TriR1:tri_state_buffer generic map(16) port map(R1out,R11out,buss);
TriR2:tri_state_buffer generic map(16) port map(R2out,R22out,buss);
TriR3:tri_state_buffer generic map(16) port map(R3out,R33out,buss);
SRc:tri_state_buffer generic map(16) port map(SOURCEout,Srcout,buss);
DEs:tri_state_buffer generic map(16) port map(DESTINout,Destout,buss);
TEm:tri_state_buffer generic map(16) port map(TEMPout,Tout,buss);

R0:my_nreg generic map(16) port map(CLK,Rst,R0in,buss,R00out);
R1:my_nreg generic map(16) port map(CLK,Rst,R1in,buss,R11out);
R2:my_nreg generic map(16) port map(CLK,Rst,R2in,buss,R22out);
PC:my_nreg generic map(16) port map(CLK,Rst,R3in,buss,R33out); --R3
Y:my_nreg generic map(16) port map(CLK,CLRY ,Yin,buss,AfromY);
SOURCE:my_nreg generic map(16) port map(CLK,Rst,SOURCEin,buss,Srcout);
DESTIN:my_nreg generic map(16) port map(CLK,Rst,DESTINin,buss,Destout);
FlagReg:my_nreg generic map(4) port map(CLK,Rst,'1',Flags,Flags);

MDR:my_nreg generic map(16) port map(CLK,Rst,mdrENABLE,mdrINPUT,ramIN);
MAR:my_nreg generic map(16) port map(CLK,Rst,MARin,buss,ADD);

-------------------------------------------------------------------------------------
ALU:ALSU port map(AfromY,buss,CARRYin,ALSU_SIGNALS,Z,Flags(0),Flags(1),Flags(2),Flags(3));
MEMORY:ram port map(CLK,RD,WR,ADD,ramIN,ramOUT,MFC);
end arch;