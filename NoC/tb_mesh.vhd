library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library STD;
use STD.textio.all;
library work;
use work.defs.all;

entity tb_mesh is
	-- Nothing here
end tb_mesh;


architecture testbench of tb_mesh is
	-- MxN matrix
	constant M : positive := 3;	-- Rows
	constant N : positive := 3;	-- Columns

	type row_fwd is array(-1 to (N + 0)) of channel_forward;
	type fwd_t is array(-1 to (M + 0)) of row_fwd;
	type row_bck is array(-1 to (N + 0)) of channel_backward;
	type bck_t is array(-1 to (M + 0)) of row_bck;
	signal n2s_f, s2n_f, e2w_f, w2e_f : fwd_t;
	signal n2s_b, s2n_b, e2w_b, w2e_b : bck_t;

	-- For resource
	type r_row_fwd is array(0 to (N - 1)) of channel_forward;
	type r_fwd_t is array(0 to (M - 1)) of r_row_fwd;
	type r_row_bck is array(0 to (N - 1)) of channel_backward;
	type r_bck_t is array(0 to (M - 1)) of r_row_bck;
	signal ni2r_f, r2ni_f : r_fwd_t;
	signal ni2r_b, r2ni_b : r_bck_t;

	signal preset : std_logic;
	signal sim_time : integer;



	subtype SubString_t is string (23 downto 1);
	type files_t is array(0 to (N - 1)) of SubString_t;
	type filename_t is array(0 to (M - 1)) of files_t;

	constant IN_FILES : filename_t := (("./vectors/NoC/r00_i.dat", "./vectors/NoC/r01_i.dat", "./vectors/NoC/r02_i.dat"),
									   ("./vectors/NoC/r10_i.dat", "./vectors/NoC/r11_i.dat", "./vectors/NoC/r12_i.dat"),
									   ("./vectors/NoC/r20_i.dat", "./vectors/NoC/r21_i.dat", "./vectors/NoC/r22_i.dat"));

	constant OUT_FILES : filename_t := 	(("./vectors/NoC/r00_o.dat", "./vectors/NoC/r01_o.dat", "./vectors/NoC/r02_o.dat"),
										 ("./vectors/NoC/r10_o.dat", "./vectors/NoC/r11_o.dat", "./vectors/NoC/r12_o.dat"),
										 ("./vectors/NoC/r20_o.dat", "./vectors/NoC/r21_o.dat", "./vectors/NoC/r22_o.dat"));

	constant DUMMY_FILE : SubString_t := "./vectors/NoC/dummy.dat";
begin

	init : process is
	begin
		preset <= '1', '0' after 10 ns;
		wait for 1 us;
		report ">>>>>>>>>>>>>>>>>>>>>>> Test bench finished... <<<<<<<<<<<<<<<<<<<<<<<" severity FAILURE;
	end process init;

    globa_timer : entity work.global_timer(RTL)
	generic map (
		resolution => 1 ps
	)
	port map (
		preset => preset,
		time => sim_time
	);


   switch_m : for y in 0 to (M - 1) generate
      switch_n : for x in 0 to (N - 1) generate
         switch : entity work.noc_switch(struct)
         generic map (
         	sim => true,
            x => x,
            y => y
         )
         port map (
            preset         => preset,
            -- Input ports
            north_in_f     => s2n_f(y-1)(x),
            north_in_b     => s2n_b(y-1)(x),
            east_in_f      => w2e_f(y)(x+1),
            east_in_b      => w2e_b(y)(x+1),
            south_in_f     => n2s_f(y+1)(x),
            south_in_b     => n2s_b(y+1)(x),
            west_in_f      => e2w_f(y)(x-1),
            west_in_b      => e2w_b(y)(x-1),
            resource_in_f  => r2ni_f(y)(x),
            resource_in_b  => r2ni_b(y)(x),

            -- Output ports
            north_out_f    => n2s_f(y)(x),
            north_out_b    => n2s_b(y)(x),
            east_out_f     => e2w_f(y)(x),
            east_out_b     => e2w_b(y)(x),
            south_out_f    => s2n_f(y)(x),
            south_out_b    => s2n_b(y)(x),
            west_out_f     => w2e_f(y)(x),
            west_out_b     => w2e_b(y)(x),
            resource_out_f => ni2r_f(y)(x),
            resource_out_b => ni2r_b(y)(x),

            sim_time => sim_time
         );


        producer : entity work.push_producer(behavioral)
         generic map (
            TEST_VECTORS_FILE => IN_FILES(y)(x)
         )
         port map (
            right_f => r2ni_f(y)(x),
            right_b => r2ni_b(y)(x)
         );

        consumer : entity work.eager_consumer(behavioral)
         generic map (
            TEST_VECTORS_FILE => OUT_FILES(y)(x)
         )
         port map (
            left_f => ni2r_f(y)(x),
            left_b => ni2r_b(y)(x)
         );
      end generate switch_n;
   end generate switch_m;



	top_bottom: for x in 0 to N-1 generate
		-- Act as producers
		s2n_f(-1)(x).req <= NOT s2n_b(-1)(x).ack;
		n2s_f(M)(x).req  <= NOT n2s_b(M)(x).ack;

		-- Act as consumers
		n2s_b(0)(x).ack   <= n2s_f(0)(x).req;
		s2n_b(M-1)(x).ack <= s2n_f(M-1)(x).req;
	end generate top_bottom;


	left_right: for y in 0 to M-1 generate
		-- Act as producers
		e2w_f(y)(-1).req <= NOT e2w_b(y)(-1).ack;
		w2e_f(y)(N).req  <= NOT w2e_b(y)(N).ack;

		-- Act as consumers
		w2e_b(y)(0).ack <= w2e_f(y)(0).req;
		e2w_b(y)(N-1).ack <= e2w_f(y)(N-1).req;		
	end generate left_right;


end architecture testbench;
