library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.definitions.all;



entity push_producer is
	port( 
		right_out : out channel_forward;
		right_in  : in channel_backward
	);
end entity push_producer;


architecture behav of push_producer is
begin

	-- Simulation-only construct. Synthesizable implemention would just be a NOT gate: right_out.req <= NOT right_in.ack
	sim_produce : process is
		variable cnt : natural := 40;
	begin
		right_out.req <= '0';
		right_out.data <= (others => '-');

		-- Due to initialization and loops, we start in the second half of the handshake cycle
		loop
			-- Second half of handshake
			right_out.req <= transport '0' after delay;		-- Ro-: Tell consumer that we now know it has gotten the data
			right_out.data <= (others => '-');				-- Data could be invalid now, and we are pessimistic
			wait until right_in.ack = '0';					-- Ai-: Consumer ready for next datum

			-- Wait some arbitrary "computation" time for next datum
			wait for 0.5 ns;
			
			-- First half of handshake
			right_out.data <= std_logic_vector(to_unsigned(cnt, right_out.data'length));
			right_out.req <= transport '1' after delay;					-- Ro+: Data are valid
			report "Producer sent token with data=" & integer'IMAGE(cnt) & ".";
			wait until right_in.ack = '1';								-- Ai+: Data latched in by consumer

			
			-- Only run test bench for a fixed number of tokens
			if (cnt >= 43) then
			    report "Test bench finished" severity failure;	-- Stop simulation
			else
				cnt := cnt + 1;	
			end if;
		end loop;		
	end process sim_produce;
	
end architecture behav;
