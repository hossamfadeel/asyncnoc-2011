-- ======================== (C) COPYRIGHT 2011 ============================== --
-- File Name        : consumer.vhd	   										  --
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
--                     Modified Mark Ruvald's Fibonacci consumer.             --
-- ========================================================================== --

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library STD;
use STD.textio.all;
library work;
use work.defs.all;

entity eager_consumer is
	generic (
		constant TEST_VECTORS_FILE: string := ""
	);
	port (
		left_f : in channel_forward;
		left_b : out channel_backward
	);
end entity eager_consumer;

architecture behavioral of eager_consumer is
	signal ack : std_logic := '0';
	
	signal sop : std_logic;
	signal eop : std_logic;	
	signal data : std_logic_vector(31 downto 0) := (others => '0');

	file test_vectors: text open READ_MODE is TEST_VECTORS_FILE;
begin

	sop <= left_f.data(33);
	eop <= left_f.data(32);

	-- Data
	data <= left_f.data(31 downto 0);


	-- ACK after receiving data
	ack <= transport left_f.req after DELAY;
	left_b.ack <= ack;


	reporting : process(left_f.req) is
		variable flit : word_t := (others => '0');
		variable l    : line;
	begin
		if rising_edge(left_f.req) then
			readline(test_vectors, l);
			read(l, flit);
			report "Info@eager_consumer(" & TEST_VECTORS_FILE 
				& "): SOP = " & std_logic'IMAGE(sop) 
				& ", EOP = " & std_logic'IMAGE(eop) 
				& ", Received data = " & integer'IMAGE(to_integer(unsigned(data))) 
				& "."
				severity NOTE;
		end if;
	end process reporting;

end architecture behavioral;
