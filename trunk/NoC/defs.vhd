library ieee;
use ieee.std_logic_1164.all;

package defs is
	
	constant LINKWIDTH : integer := 34;	-- 32 bit data + 2 bit EOP and SOP
	constant ARITY :integer := 5;
	subtype word_t is std_logic_vector(LINKWIDTH-1 downto 0);
	subtype onehot_sel is std_logic_vector(ARITY-1 downto 0);
	
	type link_f is record
		req : std_logic;
		data : word_t;
	end record link_f;
	
	type link_b is record
		ack : std_logic;
	end record link_b;
	
	-- Types to make design generic
	type switch_sel_t is array (ARITY-1 downto 0) of onehot_sel;
	type chs_f is array (ARITY-1 downto 0) of link_f;
	type chs_b is array (ARITY-1 downto 0) of link_b;
	type bars_t is array (ARITY-1 downto 0, ARITY-1 downto 0) of word_t;

	constant delay : time := 0.25 ns;

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
