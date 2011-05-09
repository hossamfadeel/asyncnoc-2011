library ieee;
use ieee.std_logic_1164.all;


entity conditioner is
	port (
		clk           : in  std_logic;
		async_in      : in  std_logic;
		debounced_out : out std_logic
	);
end entity conditioner;


architecture struct of conditioner is
	signal tick_en : std_logic;
	signal synced : std_logic;
begin

	-- Metastabillity filter
	synchronizer: block
		constant n : natural := 3;		-- 3 stage synchronizer should be enough
		type pipo_t is array(n-1 downto 0) of std_logic;
		signal isr : pipo_t;
	begin
		synced <= isr(n-1);		-- tap from last stage

		shift_reg:process (clk) is
		begin
			if rising_edge(clk) then
				isr(n-1 downto 1) <= isr(n-2 downto 0);	-- Shift
				isr(0) <= async_in;
			end if;
		end process shift_reg;
	end block synchronizer;


	-- Tick generator
	counter:process (clk) is
		constant max : natural := 50000;	-- 1 millisecond if clk is 50 MHz
		variable cnt : natural range 0 to max := 0;
	begin
		if rising_edge(clk) then
			if (cnt = max) then
				cnt := 0;
				tick_en <= '1';
			else
				cnt := cnt + 1;
				tick_en <= '0';
			end if;
		end if;
	end process counter;


	-- Shift in synchronized signal at each tick
	debouncer: block
		constant n : natural := 4;		-- 4 milliseconds if ticking every 1 millisecond
		type pipo_t is array(n-1 downto 0) of std_logic;
		signal isr : pipo_t;
	begin

		and_gate:process (isr) is		-- Generic n-bit wide AND gate
			variable val : std_logic;
		begin
			val := '1'; 				-- 1 is the neutral element wrt AND
			for i in 0 to n-1 loop
				val := val and isr(i);
			end loop;
			debounced_out <= val;		-- Must have been high for the last 4 ms before we set high
		end process and_gate;


		shift_reg:process (clk) is
		begin
			if rising_edge(clk) then
				if (tick_en = '1') then	-- Shift only at ticks
					isr(n-1 downto 1) <= isr(n-2 downto 0);	-- Shift
					isr(0) <= synced;	-- Shift sync'd signal in
				end if;
			end if;
		end process shift_reg;
	end block debouncer;


end architecture struct;

