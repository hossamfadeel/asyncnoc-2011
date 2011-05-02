library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library work;
use work.defs.all;

entity crossbar_stage is
	port(
		preset        : in std_logic;
		switch_sel    : in switch_sel_t;
		chs_in_f      : in chs_f;
		chs_in_b      : out chs_b;
		latches_out_f : out chs_f;
		latches_out_b : in chs_b
	);
end entity crossbar_stage;

architecture struct of crossbar_stage is
begin

	crossbar: entity work.crossbar(structural)
	generic map (
		ARITY => ARITY
		)
	port map (
		preset     => preset,
		switch_sel => switch_sel,
		chs_in_f   => chs_in_f,
		chs_in_b   => chs_in_b,
		chs_out_f  => latches_in_f,
		chs_out_b  => latches_in_b
		);
		

end architecture struct;
