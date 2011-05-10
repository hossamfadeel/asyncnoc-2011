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
	-- Nothing here
END tb_switch;


ARCHITECTURE testbench OF tb_switch IS
	SIGNAL preset : std_logic;
	TYPE ch_t IS ARRAY(0 to 4) OF channel;
	SIGNAL producer_ch : ch_t;
	SIGNAL consumer_ch : ch_t;
	
-- 	subtype SubString_t is string (9 downto 1);
-- 	TYPE filename_t IS ARRAY(0 to 4) OF SubString_t;
-- 	CONSTANT FILENAMES : filename_t := ("port0.dat", "port1.dat", "port2.dat", "port3.dat", "port4.dat");
	subtype SubString_t is string (18 downto 1);
	TYPE filename_t IS ARRAY(0 to 4) OF SubString_t;
	CONSTANT FILENAMES : filename_t := ("./vectors/n_in.dat", "./vectors/e_in.dat", "./vectors/s_in.dat", "./vectors/w_in.dat", "./vectors/r_in.dat");
BEGIN

	proc:process is
	begin
		preset <= '1', '0' after 10 ns;


		wait for 30 ns;
		report ">>>>>>>>>>>>> Test bench finished... (no test) " severity failure;		
	end process proc;
	

	-- Five instances of producers
	producers : for i in 0 to 4 generate 
		producer : entity work.push_producer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		)
		port map (
			right_f => producer_ch(i).forward,
			right_b => producer_ch(i).backward
		);
	end generate producers;


	-- Five instances of consumers
	consumers : for i in 0 to 4 generate
		consumer : entity work.eager_consumer(behavioral)
		generic map (
			TEST_VECTORS_FILE => FILENAMES(i)
		)
		port map (
			left_f  => consumer_ch(i).forward,
			left_b => consumer_ch(i).backward
		);
	end generate consumers;
	
	
	-- NoC switch instance
	switch : entity work.noc_switch(struct)
	generic map (
		x => 0,
		y => 0
	)
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
		east_out_f     => consumer_ch(1).forward,
		east_out_b     => consumer_ch(1).backward,
		south_out_f    => consumer_ch(2).forward,
		south_out_b    => consumer_ch(2).backward,
		west_out_f     => consumer_ch(3).forward,
		west_out_b     => consumer_ch(3).backward,
		resource_out_f => consumer_ch(4).forward,
		resource_out_b => consumer_ch(4).backward
	);	
END ARCHITECTURE testbench;

