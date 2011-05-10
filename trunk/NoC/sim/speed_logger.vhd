library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library work;
use work.defs.all;
use work.txt_util.all;
library std;
use std.TEXTIO.all;

entity speed_logger is
	generic(
		x_coordinate : natural;
		y_coordinate : natural
	);
	port( 
		preset : in std_logic;
		synced_req : in std_logic;
		synced_ack : in std_logic;
		reqs : in std_logic_vector(ARITY-1 downto 0);
		acks : in std_logic_vector(ARITY-1 downto 0);
		time : in integer
	);
end entity speed_logger;

architecture RTL of speed_logger is

	file l_file: TEXT open write_mode is str(x_coordinate) & "_" & str(y_coordinate) & ".log";
	--file l_file: TEXT open write_mode is "00.log";

begin
	logger:process is
		--variable l: line;
		--variable str : string;
	begin
		-- print header for the logfile
		--str := "# Log file for switch at (" & str(x_coordinate) & "," & str(y_coordinate) & ")";
		print(l_file, "# Log file for switch at (" & str(x_coordinate) & "," & str(y_coordinate) & ")");
		--print(l_file, str);
		print(l_file, "#-----------------------------");
		print(l_file, "# sync_time\t");
			
		wait until preset = '1';
		wait until preset = '0';
			  
		while true loop
			if rising_edge(synced_req) then
				print(l_file, "" & str(time));
			end if;
			--if rising_edge() then
			
			--end if;
			--print(l_file, str(x1)& " "& hstr(x2)& "h");
			
			--wait until CLK = '1';
				    
		end loop;
		
	end process logger;
	
end architecture RTL;
