Library ieee;
use ieee.std_logic_1164.all;
entity B is
  port(a,b :in std_logic_vector(15 downto 0);
        s :in std_logic_vector(1 downto 0);
        f :out std_logic_vector(15 downto 0);
		FLAGS:out std_logic_vector(3 downto 0)
		);
end B;
architecture arch1 of B is
  signal fout:std_logic_vector(15 downto 0);
  begin
    fout<= a and b when s(0)='0' and s(1) ='0' 
  else a or b when  s(0)='1' and s(1) ='0'
  else a xor b when s(0)='0' and s(1) ='1'
  else not a;
  f<=fout;  
  FLAGS(0)<= '0';  
  FLAGS(1)<='0';
  
  FLAGS(2)<='1' when fout="0000000000000000"
else '0';
  FLAGS(3)<=fout(15);
  end arch1;