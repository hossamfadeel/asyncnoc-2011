library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library work;
use work.defs.all;

entity global_timer is
	port(
		clk : in std_logic;
		time: out integer
	);
end entity global_timer;

architecture RTL of global_timer is
begin

end architecture RTL;
