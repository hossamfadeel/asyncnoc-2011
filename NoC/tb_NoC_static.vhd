-- ======================== (C) COPYRIGHT 2011 ============================== --
-- File Name        : tb_NoC.vhd                                              --
-- Author           : Madava D. Vithanage (s090912)                           --
-- Version          : v0.5                                                    --
-- Date             : 2011/05/18                                              --
-- Description      : Test Bench for a 3x3 Network-On-Chip                    --
-- ========================================================================== --
-- Environment                                                                --
-- ========================================================================== --
-- Device           :                                                         --
-- Tool Chain       : Xilinx ISE Webpack 13.1                                 --
-- ========================================================================== --
-- Revision History                                                           --
-- ========================================================================== --
-- 2011/05/18 - v0.5 - Initial release.                                       --
-- ========================================================================== --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY STD;
USE STD.TEXTIO.ALL;
LIBRARY WORK;
USE WORK.defs.ALL;

ENTITY tb_NoC IS
END tb_NoC;

ARCHITECTURE testbench OF tb_NoC IS
	SIGNAL preset : std_logic;
	
	type ch_t is array(0 to 8) of channel;
	signal producer_ch : ch_t;
	signal consumer_ch : ch_t;
	
	type chan_t is array(0 to 5) of channel;
   signal dummy_ns_in_ch : chan_t;
   signal dummy_ew_in_ch : chan_t;
   signal dummy_ns_out_ch : chan_t;
   signal dummy_ew_out_ch : chan_t;
   
   signal chan_ns_in_ch : chan_t;
   signal chan_ew_in_ch : chan_t;
   signal chan_ns_out_ch : chan_t;
   signal chan_ew_out_ch : chan_t;
	
	subtype file_t is string (23 downto 1);
	type files_t is array(0 to 8) of file_t;
   
   signal sim_time : integer;
   
   CONSTANT IN_FILES : files_t := ("./vectors/NoC/r00_i.dat", "./vectors/NoC/r01_i.dat", "./vectors/NoC/r02_i.dat",
                                   "./vectors/NoC/r10_i.dat", "./vectors/NoC/r11_i.dat", "./vectors/NoC/r12_i.dat",
                                   "./vectors/NoC/r20_i.dat", "./vectors/NoC/r21_i.dat", "./vectors/NoC/r22_i.dat");

   CONSTANT OUT_FILES : files_t := ("./vectors/NoC/r00_o.dat", "./vectors/NoC/r01_o.dat", "./vectors/NoC/r02_o.dat",
                                    "./vectors/NoC/r10_o.dat", "./vectors/NoC/r11_o.dat", "./vectors/NoC/r12_o.dat",
                                    "./vectors/NoC/r20_o.dat", "./vectors/NoC/r21_o.dat", "./vectors/NoC/r22_o.dat");
   
   CONSTANT DUMMY_FILE : file_t := "./vectors/NoC/dummy.dat";           
BEGIN

   init : process is
   begin
      preset <= '1', '0' after 10 ns;
      wait for 350 ns;

      report ">>>>>>>>>>>>>>>>>>>>>>> Test bench finished... <<<<<<<<<<<<<<<<<<<<<<<" 
      severity failure;
   end process init;
   
   -- Nine producers
   producers : for i in 0 to 8 generate
      producer : entity work.push_producer(behavioral)
      generic map (
         TEST_VECTORS_FILE => IN_FILES(i)
      )
      port map (
	     -- out
         right_f => producer_ch(i).forward,
		 -- in
         right_b => producer_ch(i).backward
      );
   end generate producers;

   -- Nine consumers
	consumers : for i in 0 to 8 generate
     consumer : entity work.eager_consumer(behavioral)
      generic map (
         TEST_VECTORS_FILE => OUT_FILES(i)
      )
      port map (
	     -- in
         left_f => consumer_ch(i).forward,
		 -- out
         left_b => consumer_ch(i).backward
      ); 
   end generate consumers;
   
   -- Six north/south dummy producers
   producers_dummy_ns : for i in 0 to 5 generate
      producer : entity work.push_producer(behavioral)
      generic map (
         TEST_VECTORS_FILE => DUMMY_FILE
      )
      port map (
	     -- out
         right_f => dummy_ns_in_ch(i).forward,
		 -- in
         right_b => dummy_ns_in_ch(i).backward
      );
   end generate producers_dummy_ns;
   
   -- Six north/south dummy consumers
   consumers_dummy_ns : for i in 0 to 5 generate
     consumer : entity work.eager_consumer(behavioral)
      generic map (
         TEST_VECTORS_FILE => DUMMY_FILE
      )
      port map (
	     -- in
         left_f => dummy_ns_out_ch(i).forward,
		 -- out
         left_b => dummy_ns_out_ch(i).backward
      ); 
   end generate consumers_dummy_ns;
   
   -- Six east/west dummy producers
   producers_dummy_ew : for i in 0 to 5 generate
      producer : entity work.push_producer(behavioral)
      generic map (
         TEST_VECTORS_FILE => DUMMY_FILE
      )
      port map (
	     -- out
         right_f => dummy_ew_in_ch(i).forward,
		 -- in
         right_b => dummy_ew_in_ch(i).backward
      );
   end generate producers_dummy_ew;
   
   -- Six east/west dummy consumers
   consumers_dummy_ew : for i in 0 to 5 generate
     consumer : entity work.eager_consumer(behavioral)
      generic map (
         TEST_VECTORS_FILE => DUMMY_FILE
      )
      port map (
	     -- in
         left_f => dummy_ew_out_ch(i).forward,
		 -- out
         left_b => dummy_ew_out_ch(i).backward
      ); 
   end generate consumers_dummy_ew;

   -- 0,0 switch with two dummy pairs   
   switch00 : entity work.noc_switch(struct)
   generic map (
      x => 0,
      y => 0
   )
   port map (
      preset         => preset,
      -- Input ports
	  -- f - in
	  -- b - out
      north_in_f     => dummy_ns_in_ch(0).forward,
      north_in_b     => dummy_ns_in_ch(0).backward,
      east_in_f      => chan_ew_in_ch(0).forward,
      east_in_b      => chan_ew_in_ch(0).backward,
      south_in_f     => chan_ns_in_ch(0).forward,
      south_in_b     => chan_ns_in_ch(0).backward,
      west_in_f      => dummy_ew_in_ch(3).forward,
      west_in_b      => dummy_ew_in_ch(3).backward,
      resource_in_f  => producer_ch(0).forward,
      resource_in_b  => producer_ch(0).backward,
      -- Output ports
	  -- f - out
	  -- b - in
      north_out_f    => dummy_ns_out_ch(0).forward,
      north_out_b    => dummy_ns_out_ch(0).backward,
      east_out_f     => chan_ew_out_ch(0).forward,
      east_out_b     => chan_ew_out_ch(0).backward,
      south_out_f    => chan_ns_out_ch(0).forward,
      south_out_b    => chan_ns_out_ch(0).backward,
      west_out_f     => dummy_ew_out_ch(3).forward,
      west_out_b     => dummy_ew_out_ch(3).backward,
      resource_out_f => consumer_ch(0).forward,
      resource_out_b => consumer_ch(0).backward,
            
	  sim_time => sim_time
   );
   
   -- 0,1 switch with one dummy pair   
   switch01 : entity work.noc_switch(struct)
   generic map (
      x => 1,
      y => 0
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => dummy_ns_in_ch(1).forward,
      north_in_b     => dummy_ns_in_ch(1).backward,
      east_in_f      => chan_ew_in_ch(1).forward,
      east_in_b      => chan_ew_in_ch(1).backward,
      south_in_f     => chan_ns_in_ch(1).forward,
      south_in_b     => chan_ns_in_ch(1).backward,
      west_in_f      => chan_ew_out_ch(0).forward,
      west_in_b      => chan_ew_out_ch(0).backward,
      resource_in_f  => producer_ch(1).forward,
      resource_in_b  => producer_ch(1).backward,
      -- Output ports
      north_out_f    => dummy_ns_out_ch(1).forward,
      north_out_b    => dummy_ns_out_ch(1).backward,
      east_out_f     => chan_ew_out_ch(1).forward,
      east_out_b     => chan_ew_out_ch(1).backward,
      south_out_f    => chan_ns_out_ch(1).forward,
      south_out_b    => chan_ns_out_ch(1).backward,
      west_out_f     => chan_ew_in_ch(0).forward,
      west_out_b     => chan_ew_in_ch(0).backward,
      resource_out_f => consumer_ch(1).forward,
      resource_out_b => consumer_ch(1).backward,
            
	  sim_time => sim_time
   );
   
   -- 0,2 switch with two dummy pairs   
   switch02 : entity work.noc_switch(struct)
   generic map (
      x => 2,
      y => 0
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => dummy_ns_in_ch(2).forward,
      north_in_b     => dummy_ns_in_ch(2).backward,
      east_in_f      => dummy_ew_in_ch(0).forward,
      east_in_b      => dummy_ew_in_ch(0).backward,
      south_in_f     => chan_ns_in_ch(2).forward,
      south_in_b     => chan_ns_in_ch(2).backward,
      west_in_f      => chan_ew_out_ch(1).forward,
      west_in_b      => chan_ew_out_ch(1).backward,
      resource_in_f  => producer_ch(2).forward,
      resource_in_b  => producer_ch(2).backward,
      -- Output ports
      north_out_f    => dummy_ns_out_ch(2).forward,
      north_out_b    => dummy_ns_out_ch(2).backward,
      east_out_f     => dummy_ew_out_ch(0).forward,
      east_out_b     => dummy_ew_out_ch(0).backward,
      south_out_f    => chan_ns_out_ch(2).forward,
      south_out_b    => chan_ns_out_ch(2).backward,
      west_out_f     => chan_ew_in_ch(1).forward,
      west_out_b     => chan_ew_in_ch(1).backward,
      resource_out_f => consumer_ch(2).forward,
      resource_out_b => consumer_ch(2).backward,
            
	  sim_time => sim_time
   );
   
   -- 1,0 switch with one dummy pair   
   switch10 : entity work.noc_switch(struct)
   generic map (
      x => 0,
      y => 1
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(0).forward,
      north_in_b     => chan_ns_out_ch(0).backward,
      east_in_f      => chan_ew_in_ch(2).forward,
      east_in_b      => chan_ew_in_ch(2).backward,
      south_in_f     => chan_ns_in_ch(3).forward,
      south_in_b     => chan_ns_in_ch(3).backward,
      west_in_f      => dummy_ew_in_ch(4).forward,
      west_in_b      => dummy_ew_in_ch(4).backward,
      resource_in_f  => producer_ch(3).forward,
      resource_in_b  => producer_ch(3).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(0).forward,
      north_out_b    => chan_ns_in_ch(0).backward,
      east_out_f     => chan_ew_out_ch(2).forward,
      east_out_b     => chan_ew_out_ch(2).backward,
      south_out_f    => chan_ns_out_ch(3).forward,
      south_out_b    => chan_ns_out_ch(3).backward,
      west_out_f     => dummy_ew_out_ch(4).forward,
      west_out_b     => dummy_ew_out_ch(4).backward,
      resource_out_f => consumer_ch(3).forward,
      resource_out_b => consumer_ch(3).backward,
            
	  sim_time => sim_time
   );
   
   -- 1,1 switch with no dummies   
   switch11 : entity work.noc_switch(struct)
   generic map (
      x => 1,
      y => 1
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(1).forward,
      north_in_b     => chan_ns_out_ch(1).backward,
      east_in_f      => chan_ew_in_ch(3).forward,
      east_in_b      => chan_ew_in_ch(3).backward,
      south_in_f     => chan_ns_in_ch(4).forward,
      south_in_b     => chan_ns_in_ch(4).backward,
      west_in_f      => chan_ew_out_ch(2).forward,
      west_in_b      => chan_ew_out_ch(2).backward,
      resource_in_f  => producer_ch(4).forward,
      resource_in_b  => producer_ch(4).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(1).forward,
      north_out_b    => chan_ns_in_ch(1).backward,
      east_out_f     => chan_ew_out_ch(3).forward,
      east_out_b     => chan_ew_out_ch(3).backward,
      south_out_f    => chan_ns_out_ch(4).forward,
      south_out_b    => chan_ns_out_ch(4).backward,
      west_out_f     => chan_ew_in_ch(2).forward,
      west_out_b     => chan_ew_in_ch(2).backward,
      resource_out_f => consumer_ch(4).forward,
      resource_out_b => consumer_ch(4).backward,
            
	  sim_time => sim_time
   );
   
   -- 1,2 switch with one dummy pair   
   switch12 : entity work.noc_switch(struct)
   generic map (
      x => 2,
      y => 1
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(2).forward,
      north_in_b     => chan_ns_out_ch(2).backward,
      east_in_f      => dummy_ew_in_ch(1).forward,
      east_in_b      => dummy_ew_in_ch(1).backward,
      south_in_f     => chan_ns_in_ch(5).forward,
      south_in_b     => chan_ns_in_ch(5).backward,
      west_in_f      => chan_ew_out_ch(3).forward,
      west_in_b      => chan_ew_out_ch(3).backward,
      resource_in_f  => producer_ch(5).forward,
      resource_in_b  => producer_ch(5).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(2).forward,
      north_out_b    => chan_ns_in_ch(2).backward,
      east_out_f     => dummy_ew_out_ch(1).forward,
      east_out_b     => dummy_ew_out_ch(1).backward,
      south_out_f    => chan_ns_out_ch(5).forward,
      south_out_b    => chan_ns_out_ch(5).backward,
      west_out_f     => chan_ew_in_ch(3).forward,
      west_out_b     => chan_ew_in_ch(3).backward,
      resource_out_f => consumer_ch(5).forward,
      resource_out_b => consumer_ch(5).backward,
            
	  sim_time => sim_time
   );
   
   -- 2,0 switch with two dummy pairs   
   switch20 : entity work.noc_switch(struct)
   generic map (
      x => 0,
      y => 2
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(3).forward,
      north_in_b     => chan_ns_out_ch(3).backward,
      east_in_f      => chan_ew_in_ch(4).forward,
      east_in_b      => chan_ew_in_ch(4).backward,
      south_in_f     => dummy_ns_in_ch(3).forward,
      south_in_b     => dummy_ns_in_ch(3).backward,
      west_in_f      => dummy_ew_in_ch(5).forward,
      west_in_b      => dummy_ew_in_ch(5).backward,
      resource_in_f  => producer_ch(6).forward,
      resource_in_b  => producer_ch(6).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(3).forward,
      north_out_b    => chan_ns_in_ch(3).backward,
      east_out_f     => chan_ew_out_ch(4).forward,
      east_out_b     => chan_ew_out_ch(4).backward,
      south_out_f    => dummy_ns_out_ch(3).forward,
      south_out_b    => dummy_ns_out_ch(3).backward,
      west_out_f     => dummy_ew_out_ch(5).forward,
      west_out_b     => dummy_ew_out_ch(5).backward,
      resource_out_f => consumer_ch(6).forward,
      resource_out_b => consumer_ch(6).backward,
            
	  sim_time => sim_time
   );
   
   -- 2,1 switch with one dummy pair   
   switch21 : entity work.noc_switch(struct)
   generic map (
      x => 1,
      y => 2
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(4).forward,
      north_in_b     => chan_ns_out_ch(4).backward,
      east_in_f      => chan_ew_in_ch(5).forward,
      east_in_b      => chan_ew_in_ch(5).backward,
      south_in_f     => dummy_ns_in_ch(4).forward,
      south_in_b     => dummy_ns_in_ch(4).backward,
      west_in_f      => chan_ew_out_ch(4).forward,
      west_in_b      => chan_ew_out_ch(4).backward,
      resource_in_f  => producer_ch(7).forward,
      resource_in_b  => producer_ch(7).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(4).forward,
      north_out_b    => chan_ns_in_ch(4).backward,
      east_out_f     => chan_ew_out_ch(5).forward,
      east_out_b     => chan_ew_out_ch(5).backward,
      south_out_f    => dummy_ns_out_ch(4).forward,
      south_out_b    => dummy_ns_out_ch(4).backward,
      west_out_f     => chan_ew_in_ch(4).forward,
      west_out_b     => chan_ew_in_ch(4).backward,
      resource_out_f => consumer_ch(7).forward,
      resource_out_b => consumer_ch(7).backward,
            
	  sim_time => sim_time
   );
   
   -- 2,2 switch with two dummy pairs   
   switch22 : entity work.noc_switch(struct)
   generic map (
      x => 2,
      y => 2
   )
   port map (
      preset         => preset,
      -- Input ports
      north_in_f     => chan_ns_out_ch(5).forward,
      north_in_b     => chan_ns_out_ch(5).backward,
      east_in_f      => dummy_ew_in_ch(2).forward,
      east_in_b      => dummy_ew_in_ch(2).backward,
      south_in_f     => dummy_ns_in_ch(5).forward,
      south_in_b     => dummy_ns_in_ch(5).backward,
      west_in_f      => chan_ew_out_ch(5).forward,
      west_in_b      => chan_ew_out_ch(5).backward,
      resource_in_f  => producer_ch(8).forward,
      resource_in_b  => producer_ch(8).backward,
      -- Output ports
      north_out_f    => chan_ns_in_ch(5).forward,
      north_out_b    => chan_ns_in_ch(5).backward,
      east_out_f     => dummy_ew_out_ch(2).forward,
      east_out_b     => dummy_ew_out_ch(2).backward,
      south_out_f    => dummy_ns_out_ch(5).forward,
      south_out_b    => dummy_ns_out_ch(5).backward,
      west_out_f     => chan_ew_in_ch(5).forward,
      west_out_b     => chan_ew_in_ch(5).backward,
      resource_out_f => consumer_ch(8).forward,
      resource_out_b => consumer_ch(8).backward,
            
	  sim_time => sim_time
   );
   
   timer : entity work.global_timer(RTL)
	generic map (
		resolution => 1 ns
	)
	port map (
		preset => preset,
		time => sim_time
	);
   
END ARCHITECTURE testbench;