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
	signal fwd4  : channel_forward;
	signal back4 : channel_backward;

	signal preset : std_logic;
begin

	-- This preset-generation is in itself, not synthesizable
	preset <= '1', '0' after 100 ns;
	

	--	Token-model:	E (E) (1) (E) (2)		Parenthesis denote tokens, no parens denotes bubble
	--	Latch-init:	    D  D   1   D   2 		D = don't care
	--					F  F   H   F   H		F=following(transparent), O=holding(opaque)

	stage1 : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_BUBBLE
	)
	port map (
		preset    => preset,
		left_in   => fwd0,
		left_out  => back0,
		right_out => fwd1,
		right_in  => back1
	);	

	stage2 : entity work.channel_latch(struct)
	generic map(
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd1,
		left_out  => back1,
		right_out => fwd2,
		right_in  => back2
	);	

	stage3 : entity work.channel_latch(struct)
	generic map (
		init_token => VALID_TOKEN,
		init_data => "00000001"	-- 1
	)
	port map (
		preset    => preset,
		left_in   => fwd2,
		left_out  => back2,
		right_out => fwd3,
		right_in  => back3
	);

	stage4 : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_TOKEN
	)
	port map (
		preset    => preset,
		left_in   => fwd3,
		left_out  => back3,
		right_out => fwd4,
		right_in  => back4
	);

	stage5 : entity work.channel_latch(struct)
	generic map (
		init_token => VALID_TOKEN,
		init_data => "00000010"	-- 2
	)
	port map (
		preset    => preset,
		left_in   => fwd4,
		left_out  => back4,
		right_out => fwd0,
		right_in  => back0
	);

end architecture struct;

