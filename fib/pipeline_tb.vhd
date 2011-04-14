library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;


entity pipeline_tb is
end pipeline_tb;


architecture n_stages of pipeline_tb is
	constant N : natural := 4;	-- Number of stages in FIFO
	type fwd_t is array(0 to N) of channel_forward;
	type bwd_t is array(0 to N) of channel_backward;
	signal fwd  : fwd_t;
	signal back : bwd_t;
begin

	producer : entity work.push_producer(behav)
	port map (
		right_out => fwd(0),
		right_in => back(0)
	);

	stages : for i in 1 to N generate
		stage : entity work.channel_latch(struct)
		port map (
			left_in   => fwd(i-1),
			left_out  => back(i-1),
			right_out => fwd(i),
			right_in  => back(i)
		);	
	end generate stages;

	consumer : entity work.eager_consumer(behav)
	port map (
		left_in  => fwd(N),
		left_out => back(N)
	);

end architecture n_stages;




-- 
-- architecture initialzed_pipeline of pipeline_tb is
-- 	signal fwd0  : channel_forward;
-- 	signal back0 : channel_backward;
-- 	signal fwd1  : channel_forward;
-- 	signal back1 : channel_backward;
-- 	signal fwd2  : channel_forward;
-- 	signal back2 : channel_backward;
-- 	signal fwd3  : channel_forward;
-- 	signal back3 : channel_backward;
-- begin
-- 
-- 	producer : entity work.push_producer(behav)
-- 	port map (
-- 		right_out => fwd0,
-- 		right_in => back0
-- 	);
-- 
-- 	stage1 : entity work.channel_latch(struct)
-- 	port map (
-- 		left_in   => fwd0,
-- 		left_out  => back0,
-- 		right_out => fwd1,
-- 		right_in  => back1
-- 	);	
-- 
-- 	stage2 : entity work.channel_latch(struct)
-- 	generic map (
-- 		init_token => valid,
-- 		init_data => "00000111"	-- 7
-- 	)
-- 	port map (
-- 		left_in   => fwd1,
-- 		left_out  => back1,
-- 		right_out => fwd2,
-- 		right_in  => back2
-- 	);
-- 	
-- 	stage3 : entity work.channel_latch(struct)
-- 	port map (
-- 		left_in   => fwd2,
-- 		left_out  => back2,
-- 		right_out => fwd3,
-- 		right_in  => back3
-- 	);	
-- 
-- 	consumer : entity work.eager_consumer(behav)
-- 	port map (
-- 		left_in  => fwd3,
-- 		left_out => back3
-- 	);
-- 
-- end architecture initialzed_pipeline;

