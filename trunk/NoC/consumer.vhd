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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE WORK.defs.ALL;

ENTITY eager_consumer IS
	GENERIC (
		TEST_VECTORS_FILE: STRING := "port.txt"
	);
	PORT ( 
		port_in  : IN channel_forward;
		port_out : OUT channel_backward
	);
END ENTITY eager_consumer;

ARCHITECTURE behavioral OF eager_consumer IS
	SIGNAL ack : STD_LOGIC := '0';
	SIGNAL status : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	SIGNAL data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	
	FILE test_vectors: TEXT OPEN read_mode is TEST_VECTORS_FILE;
BEGIN
	-- Start/End of packet
	status <= port_in.data(33 downto 32);
	-- Data
	data <= port_in.data(31 downto 0);
	
	-- ACK after receiving data
	ack <= transport port_in.req after delay;
	port_out.ack <= ack; 

	reporting : PROCESS(data, port_in, status) IS
		VARIABLE flit : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
		VARIABLE l: LINE;
		VARIABLE s: STRING(data'RANGE);
	BEGIN
		if (port_in.req = '1') then
			readline(test_vectors, l);
			read(l, s);					
			flit := to_std_logic_vector(s);
			
			case status is
				-- Header flit
				when "10" =>
					assert (data = "00" & flit(31 downto 2))
						report "Error@eager_consumer(" & TEST_VECTORS_FILE & "): SOP = " & status(1)'IMAGE & ", EOP = " & status(0)'IMAGE & ", Received data = " & INTEGER'IMAGE(to_integer(UNSIGNED(data))) & ", Expected data = " & INTEGER'IMAGE(to_integer(UNSIGNED("00" & flit(31 downto 2)))) & "."
						severity error;
				-- Body, End, or Empty flit
				when others =>
					assert (data = flit)
						report "Error@eager_consumer(" & TEST_VECTORS_FILE & "): SOP = " & status(1)'IMAGE & ", EOP = " & status(0)'IMAGE & ", Received data = " & INTEGER'IMAGE(to_integer(UNSIGNED(data))) & ", Expected data = " & INTEGER'IMAGE(to_integer(UNSIGNED(flit))) & "."
						severity error;
			end case;
		end if;		
	END PROCESS reporting;

END ARCHITECTURE behavioral;
