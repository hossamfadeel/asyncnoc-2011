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
   -- Nothing here
END tb_NoC;


ARCHITECTURE testbench OF tb_NoC IS
   -- MxN matrix
   -- Rows
   CONSTANT M : positive := 3;
   -- Columns
   CONSTANT N : positive := 3;
   
   SIGNAL preset : std_logic;
   
   type chan_t is array(0 to (N - 1)) of channel;
   type ch_t is array(0 to (M - 1)) of chan_t;
   signal producer_ch : ch_t;
   signal consumer_ch : ch_t;
   
   signal north_in : ch_t;
   signal east_in : ch_t;
   signal south_in : ch_t;
   signal west_in : ch_t;
   signal north_out : ch_t;
   signal east_out : ch_t;
   signal south_out : ch_t;
   signal west_out : ch_t;
   
   signal sim_time : integer;
   
   subtype SubString_t is string (23 downto 1);
   type files_t is array(0 to (N - 1)) of SubString_t;
   type filename_t is array(0 to (M - 1)) of files_t;
   
   CONSTANT IN_FILES : filename_t := (("./vectors/NoC/r00_i.dat", "./vectors/NoC/r01_i.dat", "./vectors/NoC/r02_i.dat"),
                                      ("./vectors/NoC/r10_i.dat", "./vectors/NoC/r11_i.dat", "./vectors/NoC/r12_i.dat"),
                                      ("./vectors/NoC/r20_i.dat", "./vectors/NoC/r21_i.dat", "./vectors/NoC/r22_i.dat"));
                                      
   CONSTANT OUT_FILES : filename_t := (("./vectors/NoC/r00_o.dat", "./vectors/NoC/r01_o.dat", "./vectors/NoC/r02_o.dat"),
                                       ("./vectors/NoC/r10_o.dat", "./vectors/NoC/r11_o.dat", "./vectors/NoC/r12_o.dat"),
                                       ("./vectors/NoC/r20_o.dat", "./vectors/NoC/r21_o.dat", "./vectors/NoC/r22_o.dat"));
   
   CONSTANT DUMMY_FILE : SubString_t := "./vectors/NoC/dummy.dat";           
BEGIN

   init : process is
   begin
      preset <= '1', '0' after 10 ns;



      wait for 1 us;

      report ">>>>>>>>>>>>>>>>>>>>>>> Test bench finished... <<<<<<<<<<<<<<<<<<<<<<<" 
      severity failure;
   end process init;
   
   producers_m : for i in 0 to (M - 1) generate
      producers_n : for j in 0 to (N - 1) generate
        producer : entity work.push_producer(behavioral)
         generic map (
            TEST_VECTORS_FILE => IN_FILES(i)(j)
         )
         port map (
            right_f => producer_ch(i)(j).forward,
            right_b => producer_ch(i)(j).backward
         ); 
      end generate producers_n;      
   end generate producers_m;
   
   consumers_m : for i in 0 to (M - 1) generate
      consumers_n : for j in 0 to (N - 1) generate
        consumer : entity work.eager_consumer(behavioral)
         generic map (
            TEST_VECTORS_FILE => OUT_FILES(i)(j)
         )
         port map (
            left_f => consumer_ch(i)(j).forward,
            left_b => consumer_ch(i)(j).backward
         ); 
      end generate consumers_n;      
   end generate consumers_m;
   
   dummy_producer_m : for i in 0 to (M - 1) generate
      dummy_producer_n : for j in 0 to (N - 1) generate
         top_left : if (i = 0 and j = 0) generate
            north : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => north_in(i)(j).forward,
               right_b => north_in(i)(j).backward
            ); 
            west : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => west_in(i)(j).forward,
               right_b => west_in(i)(j).backward
            );
         end generate top_left;
         top_right : if (i = 0 and j = (N - 1)) generate
            north : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => north_in(i)(j).forward,
               right_b => north_in(i)(j).backward
            ); 
            east : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => east_in(i)(j).forward,
               right_b => east_in(i)(j).backward
            );
         end generate top_right;
         bottom_right : if (i = (M - 1) and j = (N - 1)) generate
            east : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => east_in(i)(j).forward,
               right_b => east_in(i)(j).backward
            ); 
            south : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => south_in(i)(j).forward,
               right_b => south_in(i)(j).backward
            );
         end generate bottom_right;
         bottom_left : if (i = (M - 1) and j = 0) generate
            south : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => south_in(i)(j).forward,
               right_b => south_in(i)(j).backward
            ); 
            west : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => west_in(i)(j).forward,
               right_b => west_in(i)(j).backward
            );
         end generate bottom_left;
         top_center : if (i = 0 and (j < (N - 1) and j > 0)) generate
            north : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => north_in(i)(j).forward,
               right_b => north_in(i)(j).backward
            );
         end generate top_center;
         right_center : if ((i < (M - 1) and i > 0) and j = (N - 1)) generate
            east : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => east_in(i)(j).forward,
               right_b => east_in(i)(j).backward
            );
         end generate right_center;
         bottom_center : if (i = (M - 1) and (j < (N - 1) and j > 0)) generate
            south : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => south_in(i)(j).forward,
               right_b => south_in(i)(j).backward
            );
         end generate bottom_center;
         left_center : if ((i < (M - 1) and i > 0) and j = 0) generate
            west : entity work.push_producer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               right_f => west_in(i)(j).forward,
               right_b => west_in(i)(j).backward
            );
         end generate left_center;
      end generate dummy_producer_n;      
   end generate dummy_producer_m;
   
   dummy_consumer_m : for i in 0 to (M - 1) generate
      dummy_consumer_n : for j in 0 to (N - 1) generate
         top_left : if (i = 0 and j = 0) generate
            north : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => north_out(i)(j).forward,
               left_b => north_out(i)(j).backward
            ); 
            west : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => west_out(i)(j).forward,
               left_b => west_out(i)(j).backward
            );
         end generate top_left;
         top_right : if (i = 0 and j = (N - 1)) generate
            north : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => north_out(i)(j).forward,
               left_b => north_out(i)(j).backward
            ); 
            east : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => east_out(i)(j).forward,
               left_b => east_out(i)(j).backward
            );
         end generate top_right;
         bottom_right : if (i = (M - 1) and j = (N - 1)) generate
            east : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => east_out(i)(j).forward,
               left_b => east_out(i)(j).backward
            ); 
            south : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => south_out(i)(j).forward,
               left_b => south_out(i)(j).backward
            );
         end generate bottom_right;
         bottom_left : if (i = (M - 1) and j = 0) generate
            south : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => south_out(i)(j).forward,
               left_b => south_out(i)(j).backward
            ); 
            west : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => west_out(i)(j).forward,
               left_b => west_out(i)(j).backward
            );
         end generate bottom_left;
         top_center : if (i = 0 and (j < (N - 1) and j > 0)) generate
            north : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => north_out(i)(j).forward,
               left_b => north_out(i)(j).backward
            );
         end generate top_center;
         right_center : if ((i < (M - 1) and i > 0) and j = (N - 1)) generate
            east : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => east_out(i)(j).forward,
               left_b => east_out(i)(j).backward
            );
         end generate right_center;
         bottom_center : if (i = (M - 1) and (j < (N - 1) and j > 0)) generate
            south : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => south_out(i)(j).forward,
               left_b => south_out(i)(j).backward
            );
         end generate bottom_center;
         left_center : if ((i < (M - 1) and i > 0) and j = 0) generate
            west : entity work.eager_consumer(behavioral)
            generic map (
               TEST_VECTORS_FILE => DUMMY_FILE
            )
            port map (
               left_f => west_out(i)(j).forward,
               left_b => west_out(i)(j).backward
            );
         end generate left_center;
      end generate dummy_consumer_n;      
   end generate dummy_consumer_m;

   switch_m : for i in 0 to (M - 1) generate
      switch_n : for j in 0 to (N - 1) generate
         switch : entity work.noc_switch(struct)
         generic map (
         	sim => true,
            x => j,
            y => i
         )
         port map (
            preset         => preset,
            -- Input ports
            north_in_f     => north_in(i)(j).forward,
            north_in_b     => north_in(i)(j).backward,
            east_in_f      => east_in(i)(j).forward,
            east_in_b      => east_in(i)(j).backward,
            south_in_f     => south_in(i)(j).forward,
            south_in_b     => south_in(i)(j).backward,
            west_in_f      => west_in(i)(j).forward,
            west_in_b      => west_in(i)(j).backward,
            resource_in_f  => producer_ch(i)(j).forward,
            resource_in_b  => producer_ch(i)(j).backward,
            -- Output ports
            north_out_f    => north_out(i)(j).forward,
            north_out_b    => north_out(i)(j).backward,
            east_out_f     => east_out(i)(j).forward,
            east_out_b     => east_out(i)(j).backward,
            south_out_f    => south_out(i)(j).forward,
            south_out_b    => south_out(i)(j).backward,
            west_out_f     => west_out(i)(j).forward,
            west_out_b     => west_out(i)(j).backward,
            resource_out_f => consumer_ch(i)(j).forward,
            resource_out_b => consumer_ch(i)(j).backward,
            
            sim_time => sim_time
         );
      end generate switch_n;
   end generate switch_m;
   
    
    globa_timer : entity work.global_timer(RTL)
	generic map (
		resolution => 1 ps
		)
	port map (
		preset => preset,
		time => sim_time
		);
     
   
   channels_m : for i in 0 to (M - 1) generate
      channels_n : for j in 0 to (N - 1) generate
         right : if (i < (M - 1) and j = (N - 1)) generate
            south_in(i)(j) <= north_out(i + 1)(j);
            south_out(i)(j) <= north_in(i + 1)(j);
         end generate right;
         bottom : if (i = (M - 1) and j < (N - 1)) generate
            east_in(i)(j) <= west_out(i)(j + 1);
            east_out(i)(j) <= west_in(i)(j + 1);
         end generate bottom;
         other : if (i < (M - 1) and j < (N - 1)) generate
            east_in(i)(j) <= west_out(i)(j + 1);
            east_out(i)(j) <= west_in(i)(j + 1);
            south_in(i)(j) <= north_out(i + 1)(j);
            south_out(i)(j) <= north_in(i + 1)(j);
         end generate other;
      end generate channels_n;
   end generate channels_m;
   
END ARCHITECTURE testbench;
