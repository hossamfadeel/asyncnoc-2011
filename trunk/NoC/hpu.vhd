library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;


entity hpu is
	generic (
		constant this_port : std_logic_vector(1 downto 0)
	);
	port (
		preset    : in std_logic;

		chan_in_f : in link_f;
		chan_in_b : out link_b;
		
		chan_out_f : out link_f;
		chan_out_b : in link_b;
		
		sel : out onehot_sel
	);
end hpu;


architecture struct of hpu is
	signal sel_internal : onehot_sel;
	signal SOP : std_logic;
	signal EOP : std_logic;	

	signal hpu_out_f : link_f;
	signal hpu_out_b : link_b;
begin

	SOP <= chan_in_f.data(33);
	EOP <= chan_in_f.data(32);

	one_hot_decoder: block
		signal dest_port : std_logic_vector(1 downto 0);
	begin
		dest_port <= chan_in_f.data(1 downto 0);
		sel_internal <= "10000"	when dest_port = this_port else		-- 5: NI
						"00001" when dest_port = "00" else			-- 0: North
						"00010" when dest_port = "01" else			-- 1: East
						"00100" when dest_port = "10" else			-- 2: South
						"01000"; -- when dest_port = "11" else		-- 3: West
	end block one_hot_decoder;
	
	
	sel_latch:process (chan_in_f, chan_out_b, EOP, sel_internal, SOP) is
	begin

		-- We must only "clock" the latch when data are valid. Assume early scheme
		if (chan_in_f.req = '1' and chan_out_b.ack = '0') then
			if (SOP = '1' and EOP = '0') then
				sel <= sel_internal;
			elsif (SOP = '0' and EOP = '0') then
				-- This is an empty space, but other incoming phits may not be.
				sel <= (others => '0');	
			end if;
		end if;
	
	end process sel_latch;
	
	
	shift:process (chan_in_f, EOP, SOP) is
	begin
		if (SOP = '1' and EOP = '0') then
			hpu_out_f.data <= (others => '-');	-- shifted-in destion is don't care
			hpu_out_f.data(29 downto 0) <= chan_in_f.data(31 downto 2); -- right shift by 2 bits
			hpu_out_f.data(33) <= SOP;
			hpu_out_f.data(32) <= EOP;			
		else
			hpu_out_f.data <= chan_in_f.data;	-- Pass through unaltered
		end if;		
	end process shift;

	
	chanel_latch : entity work.channel_latch(struct)
	generic map (
		init_token => EMPTY_BUBBLE
	)
	port map (
		preset    => preset,
		left_in   => hpu_out_f,
		left_out  => hpu_out_b,
		right_out => chan_out_f,
		right_in  => chan_out_b
	);
	
	chan_in_b <= hpu_out_b;
	
	
end architecture struct;





