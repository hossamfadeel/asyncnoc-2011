library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;


entity adder is
	port (
		x_fwd : in channel_forward;
		x_bck : out channel_backward;
		y_fwd : in channel_forward;
		y_bck : out channel_backward;
		
		z_fwd : out channel_forward;
		z_bck : in channel_backward
	);
end adder;


-- Cf. figure 5.1 in S&F
architecture struct of adder is

begin
	x_bck.ack <= z_bck.ack;
	y_bck.ack <= z_bck.ack;

	gate : entity work.c_gate(latch_implementation)
	port map(
		a => x_fwd.req,
		b => y_fwd.req,
		c => z_fwd.req
	);

		

end struct;

