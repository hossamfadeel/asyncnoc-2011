LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.defs.all;


ENTITY hpu_tb IS
	-- Nothing
END hpu_tb;


ARCHITECTURE behavior OF hpu_tb IS

	--Inputs
	signal preset : std_logic;
	signal chan_in_f : channel_forward;
	signal chan_out_b : channel_backward := (ack => '0');

	--Outputs
	signal chan_in_b : channel_backward;
	signal chan_out_f : channel_forward;
	signal sel : std_logic_vector(4 downto 0);

BEGIN

	uut : entity work.hpu(struct)
	generic map (
		is_ni     => false,
		this_port => "00" -- This HPU is imagined sitting at the north-input
	)
	port map (
		preset     => preset,
		chan_in_f  => chan_in_f,
		chan_in_b  => chan_in_b,
		chan_out_f => chan_out_f,
		chan_out_b => chan_out_b,
		sel        => sel
	);

	chan_out_b.ack <= transport chan_out_f.req after 10 ns;	-- A slow consumer

	-- Stimulus process
	stim_proc: process
	begin
		preset <= '1', '0' after 5 ns;	-- hold preset high for some time in the beginning
		chan_in_f.req <= '0';	-- We don't have any new data for the consumer
		wait for 5 ns;

		-- Send an empty space phit
		chan_in_f.data <= "00" & "00000001100000000000000000000000";	-- should not be shifted, since this is not a header
		chan_in_f.req <= '1';
		wait until chan_in_b.ack = '1';
 		chan_in_f.req <= '0';


		-- Send a body phit (even though we have not yet had a header)
 		wait until chan_in_b.ack = '0';
 		chan_in_f.data <= "11" & "00000000000000000000011000000000";	-- should not be shifted, since this is not a header
 		chan_in_f.req <= '1';
		wait until chan_in_b.ack = '1';
 		chan_in_f.req <= '0';


		-- Send a body-end phit (even though we have not yet had a header)
 		wait until chan_in_b.ack = '0';
 		chan_in_f.data <= "01" & "00000000000000000000000000001100";	-- should not be shifted, since this is not a header
 		chan_in_f.req <= '1';
		wait until chan_in_b.ack = '1';
 		chan_in_f.req <= '0';


			-- Send a header phit, routing towards west
	 		wait until chan_in_b.ack = '0';
	 		chan_in_f.data <= "10" & "001010101111111111100000000000" & "11";	-- should be shifted!
	 		chan_in_f.req <= '1';
			wait until chan_in_b.ack = '1';
	 		chan_in_f.req <= '0';
	
			-- Send a body phit, routing towards west (as dictated by header)
	 		wait until chan_in_b.ack = '0';
	 		chan_in_f.data <= "11" & "00000000000000000000011111101100";	-- should not be shifted, since this is not a header
	 		chan_in_f.req <= '1';
			wait until chan_in_b.ack = '1';
	 		chan_in_f.req <= '0';
	
			-- Send a body phit, routing towards west (as dictated by header)
	 		wait until chan_in_b.ack = '0';
	 		chan_in_f.data <= "11" & "00000001101010110101011111101110";	-- should not be shifted, since this is not a header
	 		chan_in_f.req <= '1';
			wait until chan_in_b.ack = '1';
	 		chan_in_f.req <= '0';


		-- Send an empty space phit
 		wait until chan_in_b.ack = '0';
		chan_in_f.data <= "00" & "00000001100000000000000000000000";	-- should not be shifted, since this is not a header
		chan_in_f.req <= '1';
		wait until chan_in_b.ack = '1';
 		chan_in_f.req <= '0';




		wait for 40 ns;
		report ">>>>>>>>>>>>> Test bench finished... (no test) " severity failure;
	end process;

END;


