-- -----------------------------------------------------------------------------
--
--  Title      :  Testbench for task 2 of the Edge-Detection design project.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains an architecture for the testbench used in 
--             :  task 2 of the Edge-Detection design project. 
--             :
--             :
--  Revision   :  1.0    07-10-08    Initial version
--             :  1.1    08-10-09    Split data line to dataR and dataW
--             :                     Edgar <s081553@student.dtu.dk>
--             :
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen -- c973396@student.dtu.dk
--             :  Hans Holten-Lund -- hahl@imm.dtu.dk
-- -----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.types.all;

entity top is
	port (
		 clk_100mhz : in std_logic;
		 rst    : in std_logic;
		 led    : out unsigned(0 downto 0);
		 start  : in std_logic;
		 --memory interface 
		 MemOE  : out std_logic;
		 MemWR  : out std_logic;
		 MemAdv : out std_logic;
		 RamCS  : out std_logic;
		 MemClk : out std_logic;
		 RamLB  : out std_logic;
		 RamUB  : out std_logic;
		 MemAdr : out std_logic_vector(23 downto 1);
		 MemDB  : inout halfword_t
	 );
end top;

architecture structure of top is
	component ClockDivider is
		generic(div : real);
			port(reset  : in  std_logic;
			     clkIn  : in  std_logic;
			     clkOut : out std_logic
		     );
	end component;

   signal clk    : bit_t;
   signal addr   : word_t;
   signal dataR  : halfword_t;
   signal dataW  : halfword_t;
   signal req    : bit_t;
   signal rw     : bit_t;
   signal finish : bit_t;
   
   signal start_db : bit_t;
   
begin

   -- memory clock of 12.5 MHz
	-- read somewhere about the timing to be 80ns !!
	-- works faster in synchronous mode, but not tested
	clk_div_inst : ClockDivider
	generic map (div => 8.0 )
	port map ( reset => rst, clkIn => clk_100mhz, clkOut => clk);

	led(0) <= finish;
	
   Accelerator : entity work.acc
      port map (clk    => clk,
                reset  => rst,
                addr   => addr,
                dataR  => dataR,
                dataW  => dataW,
                req    => req,
                rw     => rw,
                start  => start_db,
                finish => finish);

   
   
   Memory : entity work.memory3
      port map(clk => clk,
			   rst	 => rst,
				addr   => addr,
				dataR  => dataR,
				dataW  => dataW,
				rw     => rw,
				req    => req,
			   MemOE  => MemOE,
			   MemWR  => MemWR, 
			   MemAdv => MemAdv, 
			   RamCS  => RamCS,
			   MemClk => MemClk,
			   RamLB  => RamLB,
			   RamUB  => RamUB,
			   MemAdr => MemAdr,
			   MemDB  => MemDB
			 );
			 
	Debounce : entity work.debounce
		port map(
				clk => clk,
				reset => rst,
				sw => start,
				db_level => start_db,
				db_tick => open
			);

end structure;


