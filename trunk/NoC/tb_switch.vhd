-- ======================== (C) COPYRIGHT 2011 ============================== --
-- File Name        : tb_switch.vhd	   										  --
-- Author           : Madava D. Vithanage (s090912)     					  --
-- Version          : v0.5												      --
-- Date             : 2011/04/30											  --
-- Description      : Test Bench for a single Network-On-Chip Switch          --
-- ========================================================================== --
-- Environment																  --
-- ========================================================================== --
-- Device           :                               					      --
-- Tool Chain       : Xilinx ISE Webpack 13.1                 			      --
-- ========================================================================== --
-- Revision History                                                           --
-- ========================================================================== --
-- 2011/04/30 - v0.5 - Initial release.                                       --
-- ========================================================================== --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE WORK.defs.ALL;

ENTITY tb_switch IS
END tb_switch;

ARCHITECTURE testbench OF tb_switch IS
	TYPE channel_t IS RECORD
		forward  : link_f;
		backward : link_b;
	end record channel_t;
	
	TYPE ch_t IS ARRAY(0 to 4) OF channel_t;
	SIGNAL producer_ch, consumer_ch : ch_t;
	
--	TYPE ch_f_t IS ARRAY(0 to 4) OF channel_forward;
--	TYPE ch_b_t IS ARRAY(0 to 4) OF channel_backward;
--	SIGNAL producer_ch_f : ch_f_t;
--	SIGNAL producer_ch_b : ch_b_t;
--	SIGNAL consumer_ch_f : ch_f_t;
--	SIGNAL consumer_ch_b : ch_b_t;
	
	TYPE filename_t IS ARRAY(0 to 4) OF STRING;
	VARIABLE FILENAMES   : filename_t := ("north.txt", "east.txt", "south.txt", "west.txt", "resource.txt");
BEGIN
	-- Five instances of producers
	producers : for i in 0 to 4 generate
		producer : entity work.push_producer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		);
		port map (
			port_in => producer_ch.backward(i),
			port_out => producer_ch.forward(i)
		);
	end generate producers;
	
	-- Five instances of consumers
	consumers : for i in 0 to 4 generate
		consumer : entity work.eager_consumer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		);
		port map (
			port_in  => consumer_ch.forward(i),
			port_out => consumer_ch.backward(i)
		);
	end generate consumers;
	
	-- NoC switch instance
	switch : entity work.noc_switch(structural)
	port map (
		-- Input ports
		north_in_f     => producer_ch.forward(0),
		north_in_b     => producer_ch.backward(0),
		east_in_f      => producer_ch.forward(1),
		east_in_b      => producer_ch.backward(1),
		south_in_f     => producer_ch.forward(2),
		south_in_b     => producer_ch.backward(2),
		west_in_f      => producer_ch.forward(3),
		west_in_b      => producer_ch.backward(3),
		resource_in_f  => producer_ch.forward(4),
		resource_in_b  => producer_ch.backward(4),
		-- Output ports
		north_out_f    => consumer_ch.forward(0),
		north_out_b    => consumer_ch.backward(0),
		south_out_f    => consumer_ch.forward(1),
		south_out_b    => consumer_ch.backward(1),
		east_out_f     => consumer_ch.forward(2),
		east_out_b     => consumer_ch.backward(2),
		west_out_f     => consumer_ch.forward(3),
		west_out_b     => consumer_ch.backward(3),
		resource_out_f => consumer_ch.forward(4),
		resource_out_b => consumer_ch.backward(4)
	);	
END ARCHITECTURE testbench;
