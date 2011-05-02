LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.defs.ALL;


entity noc_switch is
	port (
		north_in_f 		: in channel_forward;
		north_in_b 		: out channel_backward;    
		east_in_f      	: in channel_forward;
		east_in_b  		: out channel_backward;      
		south_in_f     	: in channel_forward;
		south_in_b     	: out channel_backward;  
		west_in_f      	: in channel_forward;
		west_in_b      	: out channel_backward;  
		resource_in_f  	: in channel_forward;
		resource_in_b  	: out channel_backward;  

		-- Output ports
		north_out_f	 	: out channel_forward;    
		north_out_b		: in channel_backward;   
		south_out_f    	: out channel_forward;   
		south_out_b    	: in channel_backward;
		east_out_f     	: out channel_forward;   
		east_out_b     	: in channel_backward;
		west_out_f     	: out channel_forward;   
		west_out_b     	: in channel_backward;
		resource_out_f 	: out channel_forward;   
		resource_out_b 	: in channel_backward
	);
end entity noc_switch;


architecture RTL of noc_switch is
begin

end architecture RTL;
