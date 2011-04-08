library ieee;
use ieee.std_logic_1164.all;




entity sr_latch is 
	port(
		s  : in std_logic;		-- set, active high		
		r  : in std_logic;		-- reset, active high
		q  : out std_logic;		-- q
		qn : out std_logic		-- q inverted
	);
end sr_latch;


architecture struct of sr_latch is
	signal q_internal, qn_internal : std_logic;
begin
	q  <= q_internal;
	qn <= qn_internal;

	-- Classic double NOR
	latch : process(r,s,q_internal,qn_internal) is
	begin
		q_internal  <= r nor qn_internal;
		qn_internal <= s nor q_internal;
	end process latch;
end struct;


architecture behav of sr_latch is
	signal q_internal, qn_internal : std_logic;
begin
	q  <= q_internal;
	qn <= qn_internal;

	-- This behavioral approach is easier for XST to recognize than a double NOR
	-- However two separate latches will be inferred
	latch : process (s, r) begin
		if (r='1' and s='0') then		-- Reset
			q_internal  <= '0';
			qn_internal <= '1';
		elsif (r='0' and s='1') then	-- Set
			q_internal  <= '1';
			qn_internal <= '0';
		elsif (r='1' and s='1') then	-- Set & Reset => invalid
			q_internal  <= 'X';
			qn_internal <= 'X';
		end if;
	end process latch;
end behav;

