library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;


entity channel_latch is
	generic (
		constant init_token : latch_state;
		constant init_data : word_t := (others => 'X')	-- Forced unknown
	);
	port (
		preset    : in std_logic;
		left_in   : in channel_forward;
		left_out  : out channel_backward;
		right_out : out channel_forward;
		right_in  : in channel_backward
	);
end channel_latch;


architecture struct of channel_latch is
	signal lt_en : latch_state;		-- Latch enable
	signal data  : word_t;			
begin
	right_out.data <= data;
	
	controller : entity work.latch_controller(simple)
	generic map(
		init_token => init_token
	)
	port map(
		preset => preset,
		Rin  => left_in.req,
		Aout => left_out.ack,
		
		Rout => right_out.req,
		Ain  => right_in.ack,

		lt_en => lt_en
	);
	
	-- Normal transparent latch, cf. figure 6.21 in S&F
	latch: process(left_in, lt_en, preset)
	begin
		if (lt_en = transparent) then
			data <= transport left_in.data after delay; -- Transparent
		end if;

		if (preset = '1') then
			data <= init_data;	-- Preset overrides the above
		end if;
	end process latch;	

end struct;

