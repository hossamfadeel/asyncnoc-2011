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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE WORK.defs.ALL;

ENTITY push_producer IS
	GENERIC (
		TEST_VECTORS_FILE: STRING := "port.txt"
	);
	PORT ( 
		port_in  : IN channel_backward;
		port_out : OUT channel_forward
	);
END ENTITY push_producer;

ARCHITECTURE behavioral OF push_producer IS
	FILE test_vectors: TEXT OPEN read_mode is TEST_VECTORS_FILE;
BEGIN
	stimulus_generate : PROCESS IS
		VARIABLE flit : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
		VARIABLE l: LINE;
		VARIABLE s: STRING(data'RANGE);		
	BEGIN
		port_out.req <= '0';
		port_out.data <= (others => '-');

		-- Due to initialization and loops, we start in the second half of the handshake cycle
		while not endfile(test_vectors) loop
			-- Second half of handshake
			port_out.req <= transport '0' after delay;		-- Ro-: Tell consumer that we now know it has gotten the data
			port_out.data <= (others => '-');				-- Data could be invalid now, and we are pessimistic
			wait until port_in.ack = '0';					-- Ai-: Consumer ready for next datum

			-- Wait some arbitrary "computation" time for next datum
			wait for 0.5 ns;
			
			-- First half of handshake
			readline(test_vectors, l);
			read(l, s);
			flit := to_std_logic_vector(s);
			
			port_out.data <= flit;
			port_out.req <= transport '1' after delay;					-- Ro+: Data are valid
			report "Info@push_producer(" & TEST_VECTORS_FILE & "): SOP = " & flit(33)'IMAGE & ", EOP = " & flit(32)'IMAGE & ", Sent data = " & INTEGER'IMAGE(to_integer(UNSIGNED(flit(31 downto 0)))) & ".";
			wait until port_in.ack = '1';								-- Ai+: Data latched in by consumer			
		end loop;		
	end process stimulus_generate;
	
END ARCHITECTURE behavioral;
