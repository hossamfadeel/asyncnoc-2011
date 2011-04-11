library IEEE;
use IEEE.STD_LOGIC_1164.all;

package definitions is

	subtype word_t is std_logic_vector(7 downto 0);

	-- Since channels are bi-directional, we must split it into two records; forwards and backwards
	type channel_forward is record
		req  : std_logic;
		data : word_t;
	end record channel_forward;
	
	type channel_backward is record
		ack  : std_logic;
	end record channel_backward;

   constant delay : time := 0.25 ns;
--    constant fwd_delay : time := 0.25 ns;
--    constant bck_delay : time := 0.25 ns;
	
	type latch_state is (hold, follow);
	type token_type is (bubble, valid);
	
end definitions;


package body definitions is 
	-- Nothing here
end definitions;
