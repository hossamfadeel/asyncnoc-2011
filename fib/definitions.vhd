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
	
	type latch_state is (opaque, transparent);

	-- Convenience constants, that add some semantics. Not type-safe!
	constant EMPTY_TOKEN  : latch_state := transparent;
	constant EMPTY_BUBBLE : latch_state := transparent;
	constant VALID_BUBBLE : latch_state := transparent;
	constant VALID_TOKEN  : latch_state := opaque;	-- Only valid-tokens are opaque latches

	-- Function prototype
	function resolve_latch_state (arg : latch_state) return std_logic;
	
end definitions;


package body definitions is 

	function resolve_latch_state (arg : latch_state) return std_logic is
	begin
		case arg is
			when transparent => return '0';	-- valid-bubbles (and all empties - also empty tokens) are transparent latches
			when others =>		return '1';	-- Only valid-tokens are opaque latches
		end case;
	end function resolve_latch_state;

end definitions;
