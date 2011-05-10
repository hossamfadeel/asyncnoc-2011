library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library work;
use work.defs.all;

entity crossbar_stage is
	generic(
		sim : boolean := true;
		x_coordinate : natural := 0;
		y_coordinate : natural := 0
	);
	port(
		preset        : in std_logic;
		switch_sel    : in switch_sel_t;
		chs_in_f      : in chs_f;
		chs_in_b      : out chs_b;
		latches_out_f : out chs_f;
		latches_out_b : in chs_b;
		
		-- Ports for simulation
		sim_time	  : in integer
	);
end entity crossbar_stage;

architecture struct of crossbar_stage is
	signal latches_in_f : chs_f;
	signal latches_in_b : chs_b;


begin

	crossbar: entity work.crossbar(structural)
	generic map (
		sim				=> sim,
		x_coordinate	=> x_coordinate,
		y_coordinate	=> y_coordinate 
	)
	port map (
		preset     => preset,
		switch_sel => switch_sel,
		chs_in_f   => chs_in_f,
		chs_in_b   => chs_in_b,
		chs_out_f  => latches_in_f,
		chs_out_b  => latches_in_b,
		sim_time   => sim_time
	);

		
 	latches: for i in ARITY-1 downto 0 generate
 		latch: block
 			signal left_in : channel_forward;
 			signal left_out : channel_backward;
 			signal right_out : channel_forward;
 			signal right_in : channel_backward;
 		begin
 			left_in          <= latches_in_f(i);
 			latches_in_b(i)  <= left_out;
 			right_in         <= latches_out_b(i);
 			latches_out_f(i) <= right_out; 
 			
 			ch_latch : entity work.channel_latch(struct)
 			generic map (
 				init_token => EMPTY_BUBBLE	
			)
 			port map (
 				preset    => preset,
 				left_in   => left_in,
 				left_out  => left_out,
 				right_out => right_out,
 				right_in  => right_in
			);	
 		end block latch;		
	end generate latches;
	
		

end architecture struct;
