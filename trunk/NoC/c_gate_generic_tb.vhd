library ieee;
use ieee.std_logic_1164.all;
 
entity c_gate_generic_tb is
	-- Nothing
end c_gate_generic_tb;

 
architecture behavior of c_gate_generic_tb is 
	 signal input : std_logic_vector(2 downto 0) := "000";
	 signal output : std_logic;
begin
	uut : entity work.c_gate_generic(sr_latch_impl)
	generic map (
		C_INIT => '1',
		WIDTH => 3
	)
	port map (
		input => input,
		output => output
	);

	-- stimulus process
	stim_proc: process
	begin
		input <= "010";
		--a <= '0'; b <= '1';		-- since a xor b = 1, output depends here on c_initial
		wait for 1 ns;

		input <= "000";
		wait for 1 ns;

		input <= "010";
		wait for 1 ns;
		input <= "011";
		wait for 1 ns;
		input <= "111";
		wait for 1 ns;

		input <= "100";
		wait for 1 ns;

		input <= "010";
		wait for 1 ns;
		input <= "011";
		wait for 1 ns;
		input <= "000";
		wait for 1 ns;
		
		input <= "111";
		wait for 1 ns;

	    report "Test bench finished" severity failure;	-- Stop simulation
	end process;

end behavior;

