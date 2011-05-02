library ieee;
use ieee.std_logic_1164.all;

package defs is
	
	constant LINKWIDTH : integer := 34;	-- 32 bit data + 2 bit EOP and SOP
	constant ARITY :integer := 5;
	subtype word_t is std_logic_vector(LINKWIDTH-1 downto 0);
	subtype onehot_sel is std_logic_vector(ARITY-1 downto 0);
	
	type channel_forward is record
		req : std_logic;
		data : word_t;
	end record channel_forward;
	
	type channel_backward is record
		ack : std_logic;
	end record channel_backward;
	
	type channel is record
		forward : channel_forward;
		backward : channel_backward;
	end record channel;
	
	
	constant delay : time := 0.25 ns;
--    constant fwd_delay : time := 0.25 ns;
--    constant bck_delay : time := 0.25 ns;
	
	-- Types to make design generic
	type switch_sel_t is array (ARITY-1 downto 0) of onehot_sel;
	type chs_f is array (ARITY-1 downto 0) of channel_forward;
	type chs_b is array (ARITY-1 downto 0) of channel_backward;
	type bars_t is array (ARITY-1 downto 0, ARITY-1 downto 0) of word_t;
	
	type latch_state is (opaque, transparent);

	-- Convenience constants, that add some semantics. Not type-safe!
	constant EMPTY_TOKEN  : latch_state := transparent;
	constant EMPTY_BUBBLE : latch_state := transparent;
	constant VALID_BUBBLE : latch_state := transparent;
	constant VALID_TOKEN  : latch_state := opaque;	-- Only valid-tokens are opaque latches

	-- Function prototype
	function resolve_latch_state (arg : latch_state) return std_logic;
	
end package defs;


package body defs is
	function resolve_latch_state (arg : latch_state) return std_logic is
	begin
		case arg is
			when transparent => return '0';	-- valid-bubbles (and all empties - also empty tokens) are transparent latches
			when others =>		return '1';	-- Only valid-tokens are opaque latches
		end case;
	end function resolve_latch_state;
end package body defs;
