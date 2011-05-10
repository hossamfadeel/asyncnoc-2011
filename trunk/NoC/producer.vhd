-- ======================== (C) COPYRIGHT 2011 ============================== --
-- File Name        : producer.vhd	   										  --
-- Author           : Madava D. Vithanage (s090912)     					  --
-- Version          : v0.5												      --
-- Date             : 2011/05/01											  --
-- Description      :                                                         --
-- ========================================================================== --
-- Environment																  --
-- ========================================================================== --
-- Device           :                               					      --
-- Tool Chain       : Xilinx ISE Webpack 13.1                 			      --
-- ========================================================================== --
-- Revision History                                                           --
-- ========================================================================== --
-- 2011/05/01 - v0.5 - Initial release.                                       --
--                     Modified Mark Ruvald's Fibonacci producer.             --
-- ========================================================================== --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library STD;
use STD.textio.all;
library work;
use work.defs.all;


entity push_producer is
	generic (
		constant TEST_VECTORS_FILE: string
	);
	port (
		right_f : out channel_forward;
		right_b  : in channel_backward
	);
end entity push_producer;


architecture behavioral of push_producer is
	file test_vectors: text open READ_MODE is TEST_VECTORS_FILE;
begin

	-- Simulation-only construct. Synthesizable implemention would just be a NOT gate: right_out.req <= NOT right_in.ack
	stimulus_generate : process  is
		variable flit : word_t := (others => '0');
		variable l    : line;
	begin
		right_f.req  <= '0';
		right_f.data <= (others => '-');

		-- Due to initialization and loops, we start in the second half of the handshake cycle
		while not endfile(test_vectors) loop
			
			-- Second half of handshake
			right_f.req <= transport '0' after DELAY;		-- Ro-: Tell consumer that we now know it has gotten the data
			right_f.data <= (others => '-');				-- Data could be invalid now, and we are pessimistic
			wait until right_b.ack = '0';					-- Ai-: Consumer ready for next datum

			-- Wait some arbitrary "computation" time for next datum
			wait for 0.5 ns;

			-- First half of handshake
			readline(test_vectors, l);
			read(l, flit);

			-- Make sure data is valid some time before raising req
			right_f.data <= flit;
			right_f.req <= transport '1' after DELAY;					-- Ro+: Data are valid
			
			report "Info@push_producer(" & TEST_VECTORS_FILE 
				& "): SOP = " 		& std_logic'IMAGE(flit(33)) 
				& ", EOP = "  		& std_logic'IMAGE(flit(32)) 
				& ", Sent data = " 	& integer'IMAGE(to_integer(unsigned(flit(31 downto 0)))) 
				& "." 
				severity NOTE;
				
			wait until right_b.ack = '1';								-- Ai+: Data latched in by consumer
		end loop;
	end process stimulus_generate;

end architecture behavioral;

