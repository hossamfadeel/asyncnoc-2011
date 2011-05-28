-- ======================== (C) COPYRIGHT 2011 ============================== --
-- File Name        : consumer.vhd	   										         --
-- Author           : Madava D. Vithanage (s090912)     					         --
-- Version          : v0.5												                  --
-- Date             : 2011/05/01											               --
-- Description      :                                                         --
-- ========================================================================== --
-- Environment																                  --
-- ========================================================================== --
-- Device           :                               					            --
-- Tool Chain       : Xilinx ISE Webpack 13.1                 			         --
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
		constant TEST_VECTORS_FILE: string
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
		variable count : natural := 0;
	begin
		if rising_edge(left_f.req) then
			readline(test_vectors, l);
			read(l, flit);
			
			count := count + 1;
			report "INFO@eager_consumer(" & TEST_VECTORS_FILE
					& "): " & integer'IMAGE(count) & " Flit received..."
				 severity note;
				 
			assert (to_integer(unsigned(left_f.data(33 downto 17))) = to_integer(unsigned(flit(33 downto 17)))) and
			       (to_integer(unsigned(left_f.data(16 downto 0))) = to_integer(unsigned(flit(16 downto 0))))
             report "ERROR@eager_consumer(" & TEST_VECTORS_FILE
					& "): Received = " & integer'IMAGE(to_integer(unsigned(left_f.data(33 downto 32)))) 
					& ", " & integer'IMAGE(to_integer(unsigned(left_f.data(31 downto 0))))
					& ", Expected = " & integer'IMAGE(to_integer(unsigned(flit(33 downto 32)))) 
					& ", " & integer'IMAGE(to_integer(unsigned(flit(31 downto 0))))
					& "."
				 severity error;
		end if;
	end process reporting;

end architecture behavioral;



