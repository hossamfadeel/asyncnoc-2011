library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.definitions.all;

entity adder is
	port (
		x_fwd : in channel_forward;
		x_bck : out channel_backward;
		y_fwd : in channel_forward;
		y_bck : out channel_backward;
		
		sum_fwd : out channel_forward;
		sum_bck : in channel_backward
	);
end adder;


architecture struct of adder is
	signal z_req : std_logic;
begin

	adder: block
		constant Tprop : time := delay * sum_fwd.data'length;	-- Increases proportionally with number of bits
	begin
		-- Make sure data is valid before req goes high; so we add 10% more delay to request
		sum_fwd.data <= transport std_logic_vector(unsigned(x_fwd.data) + unsigned(y_fwd.data)) after Tprop;
		sum_fwd.req <= transport z_req after Tprop * 1.1;		-- Have to be conservative, add 10%
	end block adder;

	-- Join x and y, producing z. Cf. figure 5.1 in S&F
	join_4phase_bundled: block
	begin
		x_bck.ack <= sum_bck.ack;
		y_bck.ack <= sum_bck.ack;
	
		gate : entity work.c_gate(latch_implementation)
		generic map (
			c_initial => '0'	-- Initially we have no request to succesor
		)
		port map(
			a => x_fwd.req,
			b => y_fwd.req,
			c => z_req
		);
	end block join_4phase_bundled;

end struct;

