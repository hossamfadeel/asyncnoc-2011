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
		constant init_token : token_type
	);
	port (
		Rin  : in std_logic;
		Aout : out std_logic;

		Rout : out std_logic;
		Ain  : in std_logic;
		
		lt_en: out latch_state	-- Latch enable
	);
end latch_controller;


-- Simple latch controller; cf. figure 2.9 in S&F
architecture simple of latch_controller is
	signal not_Ain   : std_logic; --- mangler initialization!!!!
	signal c         : std_logic;

	function resolve_token_type (arg : token_type) return std_logic is
	begin
		case arg is
			when bubble => 	return '0';	-- bubbles are transparent latches
			when others =>	return '1';	-- valids are opaque latches
		end case;
	end function resolve_token_type;
	

begin
	not_Ain   <= not Ain;		-- transport not Ain after delay;
	Rout      <= c;
	Aout      <= c;
	lt_en     <= hold 	when c = '1' else 	-- Data latch is opaque
				 follow	when c = '0';		-- Data latch is transparent
	
	gate : entity work.c_gate(latch_implementation)
	generic map (
-- 		c_initial => '0' -- bubble = data latch is transparent (ie. follow)
		c_initial => resolve_token_type(init_token)
	)
	port map(
		a => not_Ain,
		b => Rin,
		c => c
	);

end simple;
