library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;

entity xilinx_top is
	port (
		clk    : in std_logic;
		preset : in std_logic;	-- Doesn't need debouncing
		ack    : in std_logic;	-- Needs to debounced
		leds   : out word_t
	);
end entity xilinx_top;


architecture struct of xilinx_top is

	signal fib_bck : channel_backward;
	signal fib_fwd : channel_forward;
	signal clean_ack : std_logic;
	
begin
	
	-- When using buttons, operation is so fast that we don't bother to show the user req (on a separate LED)
	-- In principle he should wait for req going high, before he acknowledges back
	leds <= fib_fwd.data;
	fib_bck.ack <= clean_ack;
	
	fib : entity work.fib_generator(struct)
	port map (
		preset  => preset,
		fib_fwd => fib_fwd,
		fib_bck => fib_bck
	);
	
	debounce : entity work.conditioner(struct)
	port map (
		clk           => clk,
		async_in      => ack,
		debounced_out => clean_ack
	);

end architecture struct;

