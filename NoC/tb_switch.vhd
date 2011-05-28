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
	signal sim_time : integer;
	
	subtype SubString_t is string (17 downto 1);
	TYPE filename_t IS ARRAY(0 to 4) OF SubString_t;
	CONSTANT INPUT : filename_t := ("./vectors/n_i.dat", "./vectors/e_i.dat", "./vectors/s_i.dat", "./vectors/w_i.dat", "./vectors/r_i.dat");
	CONSTANT OUTPUT : filename_t := ("./vectors/n_o.dat", "./vectors/e_o.dat", "./vectors/s_o.dat", "./vectors/w_o.dat", "./vectors/r_o.dat");
BEGIN

	init : process is
	begin
		preset <= '1', '0' after 10 ns;
		wait for 100 ns;
		
		report ">>>>>>>>>>>>>>> Test bench finished... <<<<<<<<<<<<<<<" 
		severity failure;		
	end process init;
	

	-- Five instances of producers
	producers : for i in 0 to 4 generate 
		producer : entity work.push_producer(behavioral)
		generic map (
			TEST_VECTORS_FILE => INPUT(i)
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
			TEST_VECTORS_FILE => OUTPUT(i)
		)
		port map (
			left_f  => consumer_ch(i).forward,
			left_b => consumer_ch(i).backward
		);
	end generate consumers;
	
	
	-- NoC switch instance
	switch : entity work.noc_switch(struct)
	generic map (
		sim => true,
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
		resource_out_b => consumer_ch(4).backward,
		sim_time	   => sim_time
	);	
	
	global_time : entity work.global_timer(RTL)
	generic map (
		resolution => 1 ns
	)
	port map (
		preset => preset,
		time => sim_time
	);
	
END ARCHITECTURE testbench;
