LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY STD;
USE STD.TEXTIO.ALL;
LIBRARY WORK;
USE WORK.defs.ALL;


entity noc_switch is
	port (
		preset         : in std_logic;                   
		                                      
		-- Input ports                        
		north_in_f     : in channel_forward;  
		north_in_b     : out channel_backward;    
		east_in_f      : in channel_forward;  	
		east_in_b      : out channel_backward;      
		south_in_f     : in channel_forward;  	
		south_in_b     : out channel_backward;	  
		west_in_f      : in channel_forward;  	
		west_in_b      : out channel_backward;	  
		resource_in_f  : in channel_forward;  	
		resource_in_b  : out channel_backward;	  
                                              
		-- Output ports                       
		north_out_f    : out channel_forward;    
		north_out_b    : in channel_backward;   
		south_out_f    : out channel_forward; 	  
		south_out_b    : in channel_backward; 	
		east_out_f     : out channel_forward; 	  
		east_out_b     : in channel_backward; 	
		west_out_f     : out channel_forward; 	  
		west_out_b     : in channel_backward; 	
		resource_out_f : out channel_forward; 	  
		resource_out_b : in channel_backward  	
	);
end entity noc_switch;


architecture struct of noc_switch is
	signal north_hpu_f    : channel_forward;		-- North-in to HPU
	signal north_hpu_b    : channel_backward;		
	signal south_hpu_f    : channel_forward;
	signal south_hpu_b    : channel_backward;
	signal east_hpu_f     : channel_forward;
	signal east_hpu_b     : channel_backward;
	signal west_hpu_f     : channel_forward;
	signal west_hpu_b     : channel_backward;	
	signal resource_hpu_f : channel_forward;
	signal resource_hpu_b : channel_backward;

	signal switch_sel : switch_sel_t;
	signal chs_in_f  : chs_f;
	signal chs_in_b  : chs_b;
	
	signal latches_out_f : chs_f;
	signal latches_out_b : chs_f;

begin


	input_latches: block
	begin
		north_in_latch : entity work.channel_latch(struct)
		generic map (
			init_token => EMPTY_BUBBLE
		)
		port map (
			preset    => preset,
			left_in   => north_in_f,
			left_out  => north_in_b,
			right_out => north_hpu_f,
			right_in  => north_hpu_b
		);
	
		south_in_latch : entity work.channel_latch(struct)
		generic map (
			init_token => EMPTY_BUBBLE
		)
		port map (
			preset    => preset,
			left_in   => south_in_f,
			left_out  => south_in_b,
			right_out => south_hpu_f,
			right_in  => south_hpu_b
		);
	
		east_in_latch : entity work.channel_latch(struct)
		generic map (
			init_token => EMPTY_BUBBLE
		)
		port map (
			preset    => preset,
			left_in   => east_in_f,
			left_out  => east_in_b,
			right_out => east_hpu_f,
			right_in  => east_hpu_b
		);
	
		west_in_latch : entity work.channel_latch(struct)
		generic map (
			init_token => EMPTY_BUBBLE
		)
		port map (
			preset    => preset,
			left_in   => west_in_f,
			left_out  => west_in_b,
			right_out => west_hpu_f,
			right_in  => west_hpu_b
		);
	
		resource_in_latch : entity work.channel_latch(struct)
		generic map (
			init_token => EMPTY_BUBBLE
		)
		port map (
			preset    => preset,
			left_in   => resource_in_f,
			left_out  => resource_in_b,
			right_out => resource_hpu_f,
			right_in  => resource_hpu_b
		);
	end block input_latches;
	


	hpus: block
	begin
		north_hpu : entity work.hpu(struct)
		generic map (
			is_ni => false,
			this_port => "00"
		)
		port map (
			preset     => preset,
			chan_in_f  => north_hpu_f,
			chan_in_b  => north_hpu_b,
			chan_out_f => chs_in_f(0),
			chan_out_b => chs_in_b(0),
			sel        => switch_sel(0)		-- North is index 0
		);

		south_hpu : entity work.hpu(struct)
		generic map (
			is_ni => false,
			this_port => "10"
		)
		port map (
			preset     => preset,
			chan_in_f  => south_hpu_f,
			chan_in_b  => south_hpu_b,
			chan_out_f => chs_in_f(2),
			chan_out_b => chs_in_b(2),
			sel        => switch_sel(2)
		);

		east_hpu : entity work.hpu(struct)
		generic map (
			is_ni => false,
			this_port => "01"
		)
		port map (
			preset     => preset,
			chan_in_f  => east_hpu_f,
			chan_in_b  => east_hpu_b,
			chan_out_f => chs_in_f(1),
			chan_out_b => chs_in_b(1),
			sel        => switch_sel(1)
		);

		west_hpu : entity work.hpu(struct)
		generic map (
			is_ni => false,
			this_port => "11"
		)
		port map (
			preset     => preset,
			chan_in_f  => west_hpu_f,
			chan_in_b  => west_hpu_b,
			chan_out_f => chs_in_f(3),
			chan_out_b => chs_in_b(3),
			sel        => switch_sel(3)
		);

		resource_hpu : entity work.hpu(struct)
		generic map (
			is_ni => true,
			this_port => "--"
		)
		port map (
			preset     => preset,
			chan_in_f  => resource_hpu_f,
			chan_in_b  => resource_hpu_b,
			chan_out_f => chs_in_f(4),
			chan_out_b => chs_in_b(4),
			sel        => switch_sel(4)
		);
	end block hpus;
	
	xbar_with_latches : entity work.crossbar_stage(struct)
	port map (
		preset        => preset,
		switch_sel    => switch_sel,

		chs_in_f      => chs_in_f,
		chs_in_b      => chs_in_b,
		latches_out_f => latches_out_f,
		latches_out_b => latches_out_b
	);

	north_out_f <= latches_out_f(0);
	latches_out_b(0) <= north_out_b;

	south_out_f <= latches_out_f(2);
	latches_out_b(2) <= south_out_b;

	east_out_f <= latches_out_f(1);
	latches_out_b(1) <= east_out_b;

	west_out_f <= latches_out_f(3);
	latches_out_b(3) <= west_out_b;

	resource_out_f <= latches_out_f(4);
	latches_out_b(4) <= resource_out_b;

end architecture struct;



