library ieee;
use ieee.std_logic_1164.all;
use work.definitions.all;

entity fib_generator is
	port (
		preset  : in std_logic;

		fib_fwd : out channel_forward;
		fib_bck : in channel_backward	
	);
end entity fib_generator;


architecture struct of fib_generator is
	signal fwd_arg1 : channel_forward;		-- Two arguments to adder
	signal bck_arg1 : channel_backward;
	signal fwd_arg2 : channel_forward;
	signal bck_arg2 : channel_backward;
	signal fwd_sum  : channel_forward;		-- Result from adder
	signal bck_sum  : channel_backward;

	signal fwd_AB     : channel_forward;
	signal bck_AB     : channel_backward;
	signal fwd_Bfork1 : channel_forward;
	signal bck_Bfork1 : channel_backward;
	signal fwd_fork1arg1 : channel_forward;
	signal bck_fork1arg1 : channel_backward;
	signal fwd_fork1C : channel_forward;
	signal bck_fork1C : channel_backward;

	signal fwd_CD     : channel_forward;
	signal bck_CD     : channel_backward;
	signal fwd_Dfork2 : channel_forward;
	signal bck_Dfork2 : channel_backward;
	signal fwd_fork2arg2 : channel_forward;
	signal bck_fork2arg2 : channel_backward;
	signal fwd_fork2E : channel_forward;
	signal bck_fork2E : channel_backward;

begin
	
	arg1 : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd_fork1arg1,
		left_out  => bck_fork1arg1,
		right_out => fwd_arg1,
		right_in  => bck_arg1
	);	

	arg2 : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd_fork2arg2,
		left_out  => bck_fork2arg2,
		right_out => fwd_arg2,
		right_in  => bck_arg2
	);	

	add : entity work.adder(struct)
	port map (
		preset  => preset,
		x_fwd   => fwd_arg1,
		x_bck   => bck_arg1,
		y_fwd   => fwd_arg2,
		y_bck   => bck_arg2,

		sum_fwd => fwd_sum,
		sum_bck => bck_sum
	);	

	A : entity work.channel_latch(struct)
	generic map (
		init_token => VALID_BUBBLE -- 1
	)
	port map (
		preset    => preset,
		left_in   => fwd_sum,
		left_out  => bck_sum,
		right_out => fwd_AB,
		right_in  => bck_AB
	);	

	B : entity work.channel_latch(struct)
	generic map (
		init_token => VALID_TOKEN, -- 1
		init_data => "00000001"
	)
	port map (
		preset    => preset,
		left_in   => fwd_AB,
		left_out  => bck_AB,
		right_out => fwd_Bfork1,
		right_in  => bck_Bfork1
	);	

	fork1 : entity work.fork(struct)
	port map (
		preset => preset,
		x_fwd => fwd_Bfork1,
		x_bck => bck_Bfork1,

		y_fwd => fwd_fork1arg1,
		y_bck => bck_fork1arg1,
		z_fwd => fwd_fork1C,
		z_bck => bck_fork1C
	);

	C : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd_fork1C,
		left_out  => bck_fork1C,
		right_out => fwd_CD,
		right_in  => bck_CD
	);	

	D : entity work.channel_latch(struct)
	generic map (
		init_token => VALID_TOKEN, -- 1
		init_data => "00000001"
	)
	port map (
		preset    => preset,
		left_in   => fwd_CD,
		left_out  => bck_CD,
		right_out => fwd_Dfork2,
		right_in  => bck_Dfork2
	);	

	fork2 : entity work.fork(struct)
	port map (
		preset => preset,
		x_fwd => fwd_Dfork2,
		x_bck => bck_Dfork2,

		y_fwd => fwd_fork2arg2,
		y_bck => bck_fork2arg2,
		z_fwd => fwd_fork2E,
		z_bck => bck_fork2E
	);

	E : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd_fork2E,
		left_out  => bck_fork2E,
		right_out => fib_fwd,		-- Output channel
		right_in  => fib_bck		-- Output channel
	);	

end architecture struct;

