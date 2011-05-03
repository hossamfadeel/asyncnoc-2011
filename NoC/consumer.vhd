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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY STD;
USE STD.TEXTIO.ALL;
LIBRARY WORK;
USE WORK.defs.ALL;

ENTITY eager_consumer IS
	GENERIC (
		CONSTANT TEST_VECTORS_FILE: STRING
	);
	PORT ( 
		in_f  : IN channel_forward;
		out_b : OUT channel_backward
	);
END ENTITY eager_consumer;

ARCHITECTURE behavioral OF eager_consumer IS
	SIGNAL ack : STD_LOGIC := '0';
	SIGNAL status : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	SIGNAL data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	
	FILE test_vectors: TEXT OPEN read_mode is TEST_VECTORS_FILE;
BEGIN
	-- Start/End of packet
	status <= in_f.data(33 downto 32);
	-- Data
	data <= in_f.data(31 downto 0);
	
	-- ACK after receiving data
	ack <= transport in_f.req after delay;
	out_b.ack <= ack; 

	reporting : PROCESS(in_f.req) IS
		VARIABLE flit : STD_LOGIC_VECTOR(34 downto 0) := (others => '0');
		VARIABLE l: LINE;
	BEGIN
		if rising_edge(in_f.req) then
			readline(test_vectors, l);
			read(l, flit);					
			report "Info@eager_consumer(" & TEST_VECTORS_FILE & "): SOP = " & STD_LOGIC'IMAGE(status(1)) & ", EOP = " & STD_LOGIC'IMAGE(status(0)) & ", Received data = " & INTEGER'IMAGE(to_integer(UNSIGNED(data))) & "."
			severity note;
		end if;		
	END PROCESS reporting;

END ARCHITECTURE behavioral;
