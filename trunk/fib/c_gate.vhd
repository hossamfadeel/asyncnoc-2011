library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;


entity c_gate is
	generic (
		constant c_initial : std_logic
	);
	port (
		a : in std_logic;
		b : in std_logic;
		c : out std_logic
	);
end c_gate;


architecture latch_implementation of c_gate is
	signal set   : std_logic;
	signal reset : std_logic;	
begin
	set   <= a and b;	--   Set when a=1 and b=1
 	reset <= a nor b;	-- Reset when a=0 and b=0
	
	latch : entity work.sr_latch(struct)
	generic map(
		q_init => c_initial
	)
	port map(
		s => set,
		r => reset,
		q => c,
		qn => open	-- Not used
	);

end latch_implementation;
