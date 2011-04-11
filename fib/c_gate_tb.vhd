library ieee;
use ieee.std_logic_1164.all;
 
entity c_gate_tb is
	-- Nothing
end c_gate_tb;

 
architecture behavior of c_gate_tb is 
	 signal a : std_logic := '0';
	 signal b : std_logic := '1';
	 signal c : std_logic;
begin
	uut : entity work.c_gate(latch_implementation)
	generic map (
		c_initial => '1'
	)
	port map (
		a => a,
		b => b,
		c => c
	);

	-- stimulus process
	stim_proc: process
	begin
		a <= '0'; b <= '1';		-- since a xor b = 1, output depends here on c_initial
		wait for 1 ns;

		a <= '0'; b <= '0';
		wait for 1 ns;

		a <= '0'; b <= '1';
		wait for 1 ns;
		a <= '1'; b <= '1';
		wait for 1 ns;
		a <= '0'; b <= '1';
		wait for 1 ns;

		a <= '0'; b <= '0';
		wait for 1 ns;

		a <= '1'; b <= '0';
		wait for 1 ns;
		a <= '1'; b <= '1';
		wait for 1 ns;
		a <= '0'; b <= '1';
		wait for 1 ns;
		
		a <= '0'; b <= '0';
		wait for 1 ns;

	    report "Test bench finished" severity failure;	-- Stop simulation
	end process;

end behavior;

