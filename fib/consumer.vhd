library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.definitions.all;


entity eager_consumer is
	port(
		left_in  : in channel_forward;
		left_out : out channel_backward
	);
end entity eager_consumer;


architecture behav of eager_consumer is
	signal ack : std_logic := '0';
begin

-- 	process (left_in, reset) is
-- 	begin
-- 		if (reset = '1') then
-- 			-- Ready to consume datum
-- 			left_out.ack <= '0';
-- 		else
			-- Normal operation. Acknowledge after some delay
			
			ack <= transport left_in.req after delay; --bck_delay;
			left_out.ack <= ack; 

--			left_out.ack <= transport left_in.req after delay; --bck_delay;
-- 		end if;
-- 	end process;
	

	-- Simulation-only construct 
	sim_consume : process(left_in.req) is
	begin
		if (rising_edge(left_in.req)) then
			report "Consumer got data=" & integer'IMAGE(to_integer(unsigned(left_in.data))) & ".";
		end if;		
	end process sim_consume;

end architecture behav;
