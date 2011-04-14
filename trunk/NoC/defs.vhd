library ieee;
use ieee.std_logic_1164.all;

package defs is
	
	constant LINKWIDTH : integer := 32;
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
	
end package defs;

package body defs is
	
end package body defs;
