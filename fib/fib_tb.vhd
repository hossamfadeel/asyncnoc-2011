library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;


entity fib_tb is
	-- Nothing
end entity fib_tb;


architecture struct of fib_tb is
	signal preset  : std_logic;
	signal fib_fwd : channel_forward;
	signal fib_bck : channel_backward;
begin

	-- This preset-generation is in itself, not synthesizable
	preset <= '1', '0' after 100 ns;

	fib : entity work.fib_generator(struct)
	port map (
		preset  => preset,
		fib_fwd => fib_fwd,
		fib_bck => fib_bck
	);

	con : entity work.eager_consumer(behav)
	port map (
		left_in  => fib_fwd,
		left_out => fib_bck
	);

end architecture struct;
