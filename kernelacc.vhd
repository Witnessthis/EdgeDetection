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

constant IMG_ADDR_OOB : word_t := word_t(to_unsigned(50688, 32));
constant START_WRITE_ADDR : word_t := word_t(to_unsigned(50688, 32));

signal addrAcc, addrAcc_next : word_t;
signal currState, State_next : state_type;
signal regRow1, regRow2, regRow3 : word_t;
signal Row1MSB_next, Row1LSB_next, Row2MSB_next, Row2LSB_next, Row3MSB_next, Row3LSB_next : halfword_t;
signal regCtrlFlag, CtrlFlag_next : std_logic_vector(2 downto 0);


BEGIN

control_loop : PROCESS(currState, start, addrAcc)
BEGIN
	
	finish <= '0';
	req <= '0';
	rw <= '0';

	dataW <= (others => '0');
	addr <= addrAcc;

	addrAcc_next <= addrAcc;
	CtrlFlag_next <= regCtrlFlag;
	Row1MSB_next <= regRow1(31 downto 16);
	Row1LSB_next <= regRow1(15 downto 0);
	Row2MSB_next <= regRow2(31 downto 16);
	Row2LSB_next <= regRow2(15 downto 0);
	Row3MSB_next <= regRow3(31 downto 16);
	Row3LSB_next <= regRow3(15 downto 0);
	
	CASE (currState) IS
		WHEN idle =>
			addrAcc_next <= (others => '0');
			CtrlFlag_next <= (others => '0');
			if start = '1' then  
				req <= '1';
				rw <= '1';
				State_next <= readState;
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
			else
				State_next <= idle;
			end if;

		WHEN readState =>
			req <= '1';
			rw <= '1';
			CtrlFlag_next <= std_logic_vector(unsigned(regCtrlFlag) + 1);

			
			if (regCtrlFlag = "000") then
				Row1MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
				State_next <= readState;
				
			elsif (regCtrlFlag = "001") then
				Row1LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);

				State_next <= readState;

			elsif (regCtrlFlag = "010") then
				Row2MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);

				State_next <= readState;

			elsif (regCtrlFlag = "011") then
				Row2LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);

				State_next <= readState;

			elsif (regCtrlFlag = "100") then
				Row3MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) - 351);

				State_next <= readState;

			elsif (regCtrlFlag = "101") then
				req <= '0';
				Row3LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);

				State_next <= invert;
			end if;

		WHEN invert =>

			Row1MSB_next <= not regRow1(31 downto 16);
			Row1LSB_next <= not regRow1(15 downto 0);
			Row2MSB_next <= not regRow2(31 downto 16);
			Row2LSB_next <= not regRow2(15 downto 0);
			Row3MSB_next <= not regRow3(31 downto 16);
			Row3LSB_next <= not regRow3(15 downto 0);

			CtrlFlag_next <= (others => '0');
			addrAcc_next <= word_t(unsigned(addrAcc) + 50686);
			req <= '1';
			rw <= '0';
			State_next <= writeState;

		when writeState =>
			req <= '1';
			rw <= '0';
			CtrlFlag_next <= std_logic_vector(unsigned(regCtrlFlag) + 1);	

			if (regCtrlFlag = "000") then
				dataW <= regRow1(22 downto 16) & regRow1(31 downto 23);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				State_next <= writeState;
				
			elsif (regCtrlFlag = "001") then
				dataW <= regRow1(7 downto 0) & regRow1(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
				State_next <= writeState;
				

			elsif (regCtrlFlag = "010") then
 				dataW <= regRow1(22 downto 16) & regRow1(31 downto 23);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				State_next <= writeState;
				
			elsif (regCtrlFlag = "011") then
 				dataW <= regRow2(7 downto 0) & regRow1(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
				State_next <= writeState;

			elsif (regCtrlFlag = "100") then
 				dataW <= regRow1(22 downto 16) & regRow1(31 downto 23);
				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
				State_next <= writeState;

			elsif (regCtrlFlag = "101") then
 				dataW <= regRow3(7 downto 0) & regRow1(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) - 51039);
 				State_next <= decisionState;
			end if;

		when decisionState =>
			if (addrAcc = IMG_ADDR_OOB) then
				finish <= '1';
				State_next <= idle;
			else
				--State_next <= readState;
				State_next <= idle;

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
		regCtrlFlag <= CtrlFlag_next;
  elsif rising_edge(clk) then
		addrAcc <= addrAcc_next;
		currState <= State_next;

		regRow1 <= Row1MSB_next & Row1LSB_next;
		regRow2 <= Row2MSB_next & Row2LSB_next;
		regRow3 <= Row3MSB_next & Row3LSB_next;

		regCtrlFlag <= CtrlFlag_next;
  end if;
end process myprocess;

END structure;



