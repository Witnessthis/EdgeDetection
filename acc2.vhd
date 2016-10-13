-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be build  
--             :  in task two of the Edge Detection design project. It contains an     
--             :  architecture skeleton for the entity as well.                
--             :
--             :
--  Revision   :  1.0    7-10-08     Final version
--             :  1.1    8-10-09     Split data line to dataR and dataW
--             :                     Edgar <s081553@student.dtu.dk>
--             :  1.2   12-10-11     Changed from std_loigc_arith to numeric_std
--             :  
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen -- c973396@student.dtu.dk
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- The entity for task two. Notice the additional signals for the memory.        
-- reset is active low.
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.types.ALL;

ENTITY acc IS  
    PORT (clk :       IN    bit_t;            -- The clock.
          reset:      IN    bit_t;            -- The reset signal. Active low.
          addr:       OUT   word_t;           -- Address bus for data.
          dataR:       IN halfword_t;           -- The data bus.
          dataW:       OUT halfword_t;           -- The data bus.
          req:        OUT   bit_t;            -- Request signal for data.
          rw:         OUT   bit_t;            -- Read/Write signal for data.
          start:      IN    bit_t;
          finish:     OUT    bit_t);
END acc;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

ARCHITECTURE structure OF acc IS

-- All internal signals are defined here
-- MaxAddr = ((352*288)/2)-1 = 50687
CONSTANT MAXADDRESS : word_t := word_t(to_unsigned(50687, 32));
TYPE state_type IS (S0, S1, S2, S3, S15, S4);
SIGNAL inPixReg, outPixReg, inPixReg_next, outPixReg_next : halfword_t;
SIGNAL addrAcc, addrAcc_next : word_t;
SIGNAL s_state, s_next_state : state_type;


BEGIN

control_loop : PROCESS(s_state, start)
BEGIN
	
	finish <= '0';
	req <= '0';
	rw <= '0';
	
	CASE (s_state) IS
		WHEN S0 =>
			addrAcc_next <= (others => '0');
			if start = '1' then
				s_next_state <= S1;
			else
				s_next_state <= S0;
			end if;
		WHEN S1 =>
			req <= '1';
			rw <= '1';
			addr <= addrAcc;
			s_next_state <= S15;
		WHEN S15 =>
			inPixReg_next <= dataR;
			s_next_state <= S2;
		WHEN S2 =>
			--req <= '0';
			--outPixReg_next(15 downto 8) <= byte_t(255 - unsigned(inPixReg(15 downto 8)));
			--outPixReg_next(7 downto 0) <= byte_t(255 - unsigned(inPixReg(7 downto 0)));
			outPixReg_next <= not inPixReg;
			s_next_state <= S3;
		WHEN S3 =>
			--rw <= '0';
			req <= '1';
			DataW <= outPixReg;
			if addrAcc = MAXADDRESS then
				s_next_state <= S0;
				finish <= '1';
			else
				s_next_state <= S4;
			end if;
		WHEN S4 =>
			addrAcc_next <= word_t(unsigned(addrAcc) +1);
			s_next_state <= S1;
	END CASE;
END PROCESS control_loop;

--Template for a process
myprocess: process(clk,reset)
begin
  if reset = '1' then
		inPixReg <= (others => '0');
		outPixReg <= (others => '0');
		addrAcc <= (others => '0');
		s_state <= S0;
  elsif rising_edge(clk) then
		inPixReg <= inPixReg_next;
		outPixReg <= outPixReg_next;
		addrAcc <= addrAcc_next;
		s_state <= s_next_state;
  end if;
end process myprocess;

END structure;



