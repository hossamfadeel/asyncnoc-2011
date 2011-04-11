library ieee;
use ieee.std_logic_1164.all;
 
entity sr_latch_tb is
	-- Nothing
end sr_latch_tb;


architecture behavior of sr_latch_tb is 
	signal s : std_logic := '0';
	signal r : std_logic := '0';
	signal q : std_logic;
	signal qn : std_logic;
begin
	-- instantiate the unit under test (uut)
	uut : entity work.sr_latch(struct)
	generic map(
		q_init => '1'
	)
	port map(
		s => s,
		r => r,
		q => q,
		qn => qn
	);

	-- stimulus process
	stim_proc: process
	begin
		s <= '0'; r <= '0';
		wait for 1 ns;

	    report "Test bench finished" severity failure;	-- Stop simulation
	end process;

end behavior;
