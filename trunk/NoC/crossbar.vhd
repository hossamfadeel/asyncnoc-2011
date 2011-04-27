library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.defs.all;

entity crossbar is
	port(
		preset			: in std_logic;
		switch_sel		: in switch_sel_t;
		chs_in_f		: in chs_f;
		chs_in_b		: out chs_b;
		chs_out_f		: out chs_f;
		chs_out_b		: in chs_b
		-- Index in channel signals for ARITY = 5 are
		-- 0: North channel
		-- 1: East channel
		-- 2: South channel
		-- 3: West channel
		-- 5: Network Interface
	);
end entity crossbar;

architecture structural of crossbar is
	signal sync_req : std_logic_vector(ARITY-1 downto 0);
	signal sync_ack : std_logic_vector(ARITY-1 downto 0);
	signal synced_req : std_logic;
	signal synced_ack : std_logic;
	type latches_t is array (ARITY-1 downto 0) of channel;
	signal latches : latches_t;
begin

	output_latches: for i in ARITY-1 downto 0 generate
		latch : entity work.channel_latch(struct)
		port map (
			preset => preset,
			left_in => latches(i).forward,
			left_out => latches(i).backward,
			right_out => chs_out_f(i),
			right_in => chs_out_b(i)
			);
	end generate output_latches;
	

	c_sync_req : entity work.c_gate_generic(sr_latch_impl)
	generic map (
		C_INIT => '0',
		WIDTH => ARITY
		)
	port map (
		input => sync_req,
		output => synced_req
		);
		
	c_sync_ack : entity work.c_gate_generic(sr_latch_impl)
	generic map (
		C_INIT => '0',
		WIDTH => ARITY
		)
	port map (
		input => sync_ack,
		output => synced_ack
		);

	Sync: for i in ARITY-1 downto 0 generate
	begin
		sync_req(i) <= chs_in_f(i).req;
		latches(i).forward.req <= synced_req;
		sync_ack(i) <= latches(i).backward.ack;
		chs_in_b(i).ack <= synced_ack;
	end generate Sync;
	
	cross : process (chs_in_f, switch_sel) is
		variable bars : bars_t;
		type demux_out_t is array (ARITY-1 downto 0) of word_t;
		variable demux_out : demux_out_t; 
	begin
		-- Demux
		for i in ARITY-1 downto 0 loop
			for j in ARITY-1 downto 0 loop
				if switch_sel(i)(j) = '1' then
					bars(i,j) := chs_in_f(i).data;
				else
					bars(i,j) := (others => '0');
				end if;
			end loop;
		end loop;
		
		-- Merge
		for i in ARITY-1 downto 0 loop
			demux_out(i) := (others => '0');
			for j in ARITY-1 downto 0 loop
				demux_out(i) := demux_out(i) or bars(j,i);
			end loop;
			latches(i).forward.data <= demux_out(i);
		end loop;
		
	end process cross;
	
end architecture structural;
