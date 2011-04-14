library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;

entity fork is
	port (
		preset : in std_logic;
		x_fwd : in channel_forward;
		x_bck : out channel_backward;

		y_fwd : out channel_forward;
		y_bck : in channel_backward;
		z_fwd : out channel_forward;
		z_bck : in channel_backward
	);
end entity fork;


architecture struct of fork is
begin

	-- Fork x, producing y and z. Cf. figure 5.1 in S&F
	fork_4phase_bundled: block
	begin
		-- Just wires, no delay. Copy both data and request
		y_fwd <= x_fwd;
		z_fwd <= x_fwd;
	
		gate : entity work.c_gate(latch_implementation)
		generic map (
			c_initial => '0'	-- Initially we are ready for new token (ack=0) from predecessor
		)
		port map(
			preset => preset,
			a => y_bck.ack,
			b => z_bck.ack,
			c => x_bck.ack		-- Delay included in c_gate
		);
	end block fork_4phase_bundled;

end architecture struct;

