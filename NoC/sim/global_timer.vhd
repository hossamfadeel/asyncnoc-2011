library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library work;
use work.defs.all;

entity global_timer is
	generic(
		resolution : time := 1 ns
	);
	port(
		preset : in std_logic;
		time: out integer
	);
end entity global_timer;

architecture RTL of global_timer is
	
begin

	timer:process is
		variable timer_var : integer := 0; 
	begin
		if preset = '1' then
			timer_var := 0;
			time <= timer_var;
			wait until preset = '0';
		else
			time <= timer_var;
			wait until preset = '1' for resolution;
			timer_var := timer_var + 1;
		end if;
		
	end process timer;
	
	

end architecture RTL;
