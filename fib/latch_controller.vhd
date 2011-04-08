library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definitions.all;

--				  ____________
--      Rin ---> | Latch      | ---> Rout
--     Aout <--- | controller | <--- Ain
--		         _____________
--								Modified figure 6.21 in S&F (Aout/Ain reversed)
entity latch_controller is
	port (
		Rin  : in std_logic;
		Aout : out std_logic;

		Rout : out std_logic;
		Ain  : in std_logic;
		
		lt_en: out std_logic	-- Latch enable
	);
end latch_controller;


-- Simple latch controller; cf. figure 2.9 in S&F
architecture simple of latch_controller is
	signal not_Ain   : std_logic;
	signal c         : std_logic;
	signal c_delayed : std_logic := '0';
begin
	not_Ain   <= not Ain;
	c_delayed <= transport c after delay;
	Rout      <= c_delayed;
	Aout      <= c_delayed;
	lt_en     <= c_delayed;
	
	gate : entity work.c_gate(latch_implementation)
	port map(
		a => not_Ain,
		b => Rin,
		c => c
	);
end simple;
