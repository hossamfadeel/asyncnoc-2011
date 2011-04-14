library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;

entity ring is
end entity ring;


architecture struct of ring is
	signal fwd0  : channel_forward;
	signal back0 : channel_backward;
	signal fwd1  : channel_forward;
	signal back1 : channel_backward;
	signal fwd2  : channel_forward;
	signal back2 : channel_backward;
	signal fwd3  : channel_forward;
	signal back3 : channel_backward;
begin

	stage1 : entity work.channel_latch(struct)
	generic map (
		init_token => valid,
		init_data => "00000001"	-- 1
	)
	port map (
		left_in   => fwd0,
		left_out  => back0,
		right_out => fwd1,
		right_in  => back1
	);	

	stage2 : entity work.channel_latch(struct)
	generic map(
		init_token => bubble,
		init_data => "00000010"	-- 2, quickly overwritten since its a bubble (transparent latch)
	)
	port map (
		left_in   => fwd1,
		left_out  => back1,
		right_out => fwd2,
		right_in  => back2
	);	

	stage3 : entity work.channel_latch(struct)
	generic map (
		init_token => valid,
		init_data => "00000011"	-- 3
	)
	port map (
		left_in   => fwd2,
		left_out  => back2,
		right_out => fwd3,
		right_in  => back3
	);

	stage4 : entity work.channel_latch(struct)
	generic map (
		init_token => bubble,
		init_data => "00000100"	-- 4, quickly overwritten since its a bubble (transparent latch)
	)
	port map (
		left_in   => fwd3,
		left_out  => back3,
		right_out => fwd0,
		right_in  => back0
	);


end architecture struct;

