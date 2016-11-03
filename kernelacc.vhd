-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  Jonas Benjamin Borch - init52435@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be build  
--             :  in task two of the Edge Detection design project. It contains an     
--             :  architecture skeleton for the entity as well.                
--             :
--             :
--  Revision   :  1.0    7-10-08     Final version
--             :  1.1    8-10-09     Split data line to dataR and dataW
--             :                     Edgar <init81553@student.dtu.dk>
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
-- StartWriteAddress = 50688
type state_type IS (idle, readState, writeState, invert, decisionState);

constant MAX_ADDR : word_t := word_t(to_unsigned(50687, 32));
constant START_WRITE_ADDR : word_t := word_t(to_unsigned(50688, 32));

signal addrAcc, addrAcc_next : word_t;
signal currState, nxtState : state_type;
signal regRow1, regRow2 : word_t;
signal nxtMsbRow1, nxtLsbRow1, nxtMsbRow2, nxtLsbRow2, nxtMsbRow3, nxtLsbRow3 : halfword_t
signal regCtrlFlag, nxtCtrlFlag : std_logic_vector(2 downto 0);


BEGIN

control_loop : PROCESS(currState, start, addrAcc)
BEGIN
	
	finish <= '0';
	req <= '0';
	rw <= '0';

	dataW <= (others => '0');
	addr <= addrAcc;

	addrAcc_next <= addrAcc;
	nxtCtrlFlag <= regCtrlFlag;
	nxtRow1 <= (others => '0');
	nxtRow2 <= (others => '0');
	nxtRow3 <= (others => '0');
	
	CASE (currState) IS
		WHEN idle =>
			addrAcc_next <= (others => '0');
			nxtCtrlFlag <= (others => '0');
			if start = '1' then  
				req <= '1';
				rw <= '1';
				nxtState <= readState;
			else
				nxtState <= idle;
			end if;

		WHEN readState =>
			req <= '1';
			rw <= '1';
			
			if (regCtrlFlag = "000") then
				nxtState <= readState;
				nxtRow1(31 downto 16) <= dataR;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				
			elsif (regCtrlFlag = "001") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
				
				nxtRow1(15 downto 0) <= dataR;
				nxtState <= readState;

			elsif (regCtrlFlag = "010") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				
				nxtRow2(31 downto 16) <= dataR;
				nxtState <= readState;
			elsif (regCtrlFlag = "011") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);

				nxtRow2(15 downto 0) <= dataR;
				nxtState <= readState;

			elsif (regCtrlFlag = "100") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);

				nxtRow3(31 downto 16) <= dataR;
				nxtState <= readState;
			elsif (regCtrlFlag = "101") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);				
				addrAcc_next <= word_t(unsigned(addrAcc) - 351);

				nxtRow3(15 downto 0) <= dataR;
				nxtState <= invert;
			end if;

		WHEN invert =>
			nxtRow1 <= not regRow1;
			nxtRow2 <= not regRow2;
			nxtRow3 <= not regRow3;
			nxtCtrlFlag <= (others => '0');
			addrAcc_next <= word_t(unsigned(addrAcc) + 50686);
			req <= '1';
			rw <= '0';
			nxtState <= writeState;

		when writeState =>
			req <= '1';
			rw <= '0';

			if (regCtrlFlag = "000") then
				nxtState <= writeState;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				
				dataW <= regRow1(31 downto 16);
			elsif (regCtrlFlag = "001") then
				nxtState <= writeState;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
				
				dataW <= regRow1(15 downto 0);

			elsif (regCtrlFlag = "010") then
				nxtState <= writeState;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				
 				dataW <= regRow2(31 downto 16);
			elsif (regCtrlFlag = "011") then
				nxtState <= writeState;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);

 				dataW <= regRow2(15 downto 0);

			elsif (regCtrlFlag = "100") then
				nxtState <= writeState;
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);

 				dataW <= regRow3(31 downto 16);
			elsif (regCtrlFlag = "101") then
				nxtCtrlFlag <= std_logic_vector(unsigned(regCtrlFlag) + 1);				
				addrAcc_next <= word_t(unsigned(addrAcc) - 51037);

 				dataW <= regRow3(15 downto 0);
 				nxtState <= decisionState;
			end if;

		when decisionState =>
			if (addrAcc = MAX_ADDR) then
				finish <= '1';
				nxtState <= idle;
			else
				nxtState <= readState;
			end if ;

	END CASE;
END PROCESS control_loop;

--Template for a process
myprocess: process(clk,reset)
begin
  if reset = '1' then
		addrAcc <= (others => '0');
		currState <= idle;

		regRow1 <= (others => '0');
		regRow2 <= (others => '0');
		regRow3 <= (others => '0');
		regCtrlFlag <= nxtCtrlFlag;
  elsif rising_edge(clk) then
		addrAcc <= addrAcc_next;
		currState <= nxtState;

		regRow1 <= nxtMsbRow1 & nxtLsbRow1;
		regRow2 <= nxtMsbRow2 & nxtLsbRow2;
		regRow3 <= nxtMsbRow3 & nxtLsbRow3;

		regCtrlFlag <= nxtCtrlFlag;
  end if;
end process myprocess;

END structure;



