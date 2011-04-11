library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;


entity testbench is
end testbench;


architecture fifo of testbench is
-- 	constant N : natural := 3;	-- Number of stages in FIFO
-- 	type fwd_t is array(0 to N) of channel_forward;
-- 	type bwd_t is array(0 to N) of channel_backward;
-- 	signal fwd  : fwd_t;
-- 	signal back : bwd_t;

	signal fwd0  : channel_forward;
	signal back0 : channel_backward;
	signal fwd1  : channel_forward;
	signal back1 : channel_backward;
	signal fwd2  : channel_forward;
	signal back2 : channel_backward;
	signal fwd3  : channel_forward;
	signal back3 : channel_backward;
begin

	producer : entity work.push_producer(behav)
	port map (
		right_out => fwd0,
		right_in => back0
	);

-- 	stages : for i in 1 to N generate
-- 		stage : entity work.channel_latch(struct)
-- 		port map (
-- 			left_in   => fwd(i-1),
-- 			left_out  => back(i-1),
-- 			right_out => fwd(i),
-- 			right_in  => back(i)
-- 		);	
-- 	end generate stages;

	stage1 : entity work.channel_latch(struct)
	port map (
		left_in   => fwd0,
		left_out  => back0,
		right_out => fwd1,
		right_in  => back1
	);	
	stage2 : entity work.channel_latch(struct)
	generic map (
		init_token => valid,
		init_data => "00000111"	-- 7
	)
	port map (
		left_in   => fwd1,
		left_out  => back1,
		right_out => fwd2,
		right_in  => back2
	);	
	stage3 : entity work.channel_latch(struct)
	port map (
		left_in   => fwd2,
		left_out  => back2,
		right_out => fwd3,
		right_in  => back3
	);	


	consumer : entity work.eager_consumer(behav)
	port map (
		left_in  => fwd3,
		left_out => back3
	);

end architecture fifo;


-- architecture loopback of testbench is
--    signal fwd  : channel_forward;
--    signal back : channel_backward;
-- begin
-- 	consumer : entity work.eager_consumer(behav)
-- 	port map (
-- 		left_in => fwd,
-- 		left_out => back
-- 	);
-- 
-- 	producer : entity work.push_producer(behav)
-- 	port map (
-- 		right_out => fwd,
-- 		right_in => back
-- 	);
-- end architecture loopback;



