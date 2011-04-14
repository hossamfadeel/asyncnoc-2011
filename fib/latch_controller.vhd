library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

--				  ____________
--      Rin ---> | Latch      | ---> Rout
--     Aout <--- | controller | <--- Ain
--		         _____________
--								Modified figure 6.21 in S&F (Aout/Ain reversed)
entity latch_controller is
	generic (
		constant init_token : latch_state
	);
	port (
		preset : in std_logic;
		Rin  : in std_logic;
		Aout : out std_logic;

		Rout : out std_logic;
		Ain  : in std_logic;
		
		lt_en: out latch_state	-- Latch enable
	);
end latch_controller;


-- Simple latch controller; cf. figure 2.9 in S&F
architecture simple of latch_controller is
	signal not_Ain   : std_logic;
	signal c         : std_logic;
begin
	not_Ain   <= transport not Ain after delay;
	Rout      <= c;
	Aout      <= c;
	lt_en     <= opaque 		when c = '1' else 	-- Data latch is opaque
				 transparent	when c = '0';		-- Data latch is transparent
	
	gate : entity work.c_gate(latch_implementation)
	generic map (
		c_initial => resolve_latch_state(init_token)
	)
	port map(
		preset => preset,
		a => not_Ain,
		b => Rin,
		c => c
	);

end simple;
