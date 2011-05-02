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
LIBRARY STD;
USE STD.TEXTIO.ALL;
LIBRARY WORK;
USE WORK.defs.ALL;

ENTITY tb_switch IS
END tb_switch;

ARCHITECTURE testbench OF tb_switch IS
	signal preset : std_logic;
	TYPE ch_t IS ARRAY(0 to 4) OF channel;
	SIGNAL producer_ch : ch_t;
	signal consumer_ch : ch_t;

	TYPE filename_t IS ARRAY(0 to 4) OF STRING;
	VARIABLE FILENAMES   : filename_t := ("north.txt", "east.txt", "south.txt", "west.txt", "resource.txt");
BEGIN
	preset <= '1', '0' after 100 ns;
	
	-- Five instances of producers
	producers : for i in 0 to 4 generate
		producer : entity work.push_producer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		)
		port map (
			in_b => producer_ch(i).backward,
			out_f => producer_ch(i).forward
		);
	end generate producers;
	
	-- Five instances of consumers
	consumers : for i in 0 to 4 generate
		consumer : entity work.eager_consumer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		)
		port map (
			in_f  => consumer_ch(i).forward,
			out_b => consumer_ch(i).backward
		);
	end generate consumers;
	
	
	-- NoC switch instance
	switch : entity work.noc_switch(struct)
	port map (
		preset         => preset,
		-- Input ports
		north_in_f     => producer_ch(0).forward,
		north_in_b     => producer_ch(0).backward,
		east_in_f      => producer_ch(1).forward,
		east_in_b      => producer_ch(1).backward,
		south_in_f     => producer_ch(2).forward,
		south_in_b     => producer_ch(2).backward,
		west_in_f      => producer_ch(3).forward,
		west_in_b      => producer_ch(3).backward,
		resource_in_f  => producer_ch(4).forward,
		resource_in_b  => producer_ch(4).backward,
		-- Output ports
		north_out_f    => consumer_ch(0).forward,
		north_out_b    => consumer_ch(0).backward,
		south_out_f    => consumer_ch(1).forward,
		south_out_b    => consumer_ch(1).backward,
		east_out_f     => consumer_ch(2).forward,
		east_out_b     => consumer_ch(2).backward,
		west_out_f     => consumer_ch(3).forward,
		west_out_b     => consumer_ch(3).backward,
		resource_out_f => consumer_ch(4).forward,
		resource_out_b => consumer_ch(4).backward
	);	
END ARCHITECTURE testbench;
