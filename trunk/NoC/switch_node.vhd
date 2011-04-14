library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

entity switch_node is
	port(
		rst				: in std_logic;
		chs_in_f		: in chs_f;
		chs_in_b		: out chs_b;
		chs_out_f		: out chs_f;
		chs_out_b		: in chs_b
		-- Index in channel signals for ARITY = 5 are
		-- 0: Network Interface
		-- 1: North channel
		-- 2: East channel
		-- 3: South channel
		-- 4: West channel
	);
end entity switch_node;

architecture struct of switch_node is
begin

end architecture struct;
