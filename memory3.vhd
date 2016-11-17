----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:07:28 10/04/2012 
-- Design Name: 
-- Module Name:    psram_ctrl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
USE WORK.types.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory3 is
	port (
		     clk : in std_logic;
		     rst : in std_logic;
	 -- from internal design 
		     addr : in word_t;
		     dataR : out halfword_t;
		     dataW : in halfword_t;
			 req : in std_logic;
		     rw : in std_logic;

    -- to external memory
		     MemOE : out std_logic;
		     MemWR : out std_logic;
		     MemAdv : out std_logic;
		     RamCS : out std_logic;
		     MemClk : out std_logic;
		     RamLB : out std_logic;
		     RamUB : out std_logic;
		     MemAdr : out std_logic_vector(23 downto 1);
		     MemDB : inout halfword_t
	     );
end memory3;

architecture Behavioral of memory3 is
	signal wr_en : std_logic;

begin

-- asynchronous mode !!
	MemClk <= '0';
-- always enabled chip select
	RamCS <= not req;
	MemAdv <= '0';
	RamLB <= '0';
	RamUB <= '0';
	wr_en <= not rw;


	process(MemDB,dataW,addr,wr_en)
	begin
		dataR <= MemDB;
		MemAdr <= addr(22 downto 0);
		if ( wr_en = '1' ) then
			MemWR <= '0';
			MemOE <= '1';
			MemDB <= dataW;
		else
			MemOE <= '0';
			MemWR <= '1';
			MemDB <= (others => 'Z');
		end if;
	end process;

end Behavioral;

