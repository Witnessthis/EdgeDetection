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
type state_type IS (idle, readStateMSB, readStateLSB, writeState, invert, decisionState, waitForInvert);

constant IMG_ADDR_OOB : word_t := word_t(to_unsigned(50688, 32));
constant START_WRITE_ADDR : word_t := word_t(to_unsigned(50688, 32));
constant STRIDE_SIZE : byte_t := byte_t(to_unsigned(175, 8));

signal addrAcc, addrAcc_next : word_t;
signal currState, State_next : state_type;
signal regRow1, regRow2, regRow3 : word_t;
signal newPixelReg, newPixelReg_next : halfword_t;
signal Row1MSB_next, Row1LSB_next, Row2MSB_next, Row2LSB_next, Row3MSB_next, Row3LSB_next : halfword_t;
signal regCtrlFlag, CtrlFlag_next : std_logic_vector(2 downto 0);
signal strideCounter, strideCounter_next : byte_t;
signal D1, D2, D1Shifted, D2Shifted : halfword_t;
signal As11, As12, As13, As21, As23, As31, As32, As33, Bs11, Bs12, Bs13, Bs21, Bs23, Bs31, Bs32, Bs33 : signed(15 downto 0);
signal sub1, sub2, sub3, sub4, sub5, sub6, Aadd1, Aadd2, Badd1, Badd2 :signed(15 downto 0);
BEGIN

control_loop : PROCESS(currState, start, addrAcc, regCtrlFlag, CtrlFlag_next, regRow1, regRow2, regRow3, dataR, strideCounter, strideCounter_next)
BEGIN
	
	finish <= '0';
	req <= '0';
	rw <= '0';
	strideCounter_next <= strideCounter;
	dataW <= (others => '0');
	addr <= addrAcc;
	State_next <= idle;
	addrAcc_next <= addrAcc;
	CtrlFlag_next <= regCtrlFlag;
	Row1MSB_next <= regRow1(31 downto 16);
	Row1LSB_next <= regRow1(15 downto 0);
	Row2MSB_next <= regRow2(31 downto 16);
	Row2LSB_next <= regRow2(15 downto 0);
	Row3MSB_next <= regRow3(31 downto 16);
	Row3LSB_next <= regRow3(15 downto 0);
	newPixelReg_next <= newPixelReg;
	
	CASE (currState) IS
		WHEN idle =>
			addrAcc_next <= (others => '0');
			CtrlFlag_next <= (others => '0');
			if start = '1' then  
				State_next <= readStateMSB;
			else
				State_next <= idle;
			end if;

		WHEN readStateMSB =>
			req <= '1';
			rw <= '1';
			CtrlFlag_next <= std_logic_vector(unsigned(regCtrlFlag) + 1);

			if (regCtrlFlag = "000") then
				Row1MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 176);
				State_next <= readStateMSB;

			elsif (regCtrlFlag = "001") then
				Row2MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 176);
				State_next <= readStateMSB;

			elsif (regCtrlFlag = "010") then
				Row3MSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) - 351);
				State_next <= readStateLSB;
				CtrlFlag_next <= (others => '0');

			end if;

		WHEN readStateLSB =>
			req <= '1';
			rw <= '1';
			CtrlFlag_next <= std_logic_vector(unsigned(regCtrlFlag) + 1);
			
			if (regCtrlFlag = "000") then
				Row1LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 176);
				State_next <= readStateLSB;

			elsif (regCtrlFlag = "001") then
				Row2LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) + 176);
				State_next <= readStateLSB;

			elsif (regCtrlFlag = "010") then
				Row3LSB_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				addrAcc_next <= word_t(unsigned(addrAcc) - 351);
				State_next <= invert;
				strideCounter_next <= byte_t(unsigned(strideCounter)+1);
			end if;
		

		WHEN invert =>

			As11 <= signed("00000000" & regRow1(31 downto 24)); 
			As12 <= signed("00000000" & regRow1(23 downto 16)); 
			As13 <= signed("00000000" & regRow1(15 downto 8)); 
			--As21 <= shift_left(signed("00000000" & regRow2(31 downto 24)), 1);
			--As23 <= shift_left(signed("00000000" & regRow2(15 downto 8)), 1); 
			As21 <= signed("00000000" & regRow2(31 downto 24));
			As23 <= signed("00000000" & regRow2(15 downto 8)); 
			As31 <= signed("00000000" & regRow3(31 downto 24)); 
			As32 <= signed("00000000" & regRow3(23 downto 16)); 
			As33 <= signed("00000000" & regRow3(15 downto 8)); 

			Bs11 <= signed("00000000" & regRow1(23 downto 16));
			--Bs12 <= shift_left(signed("00000000" & regRow1(15 downto 8)), 1);
			Bs12 <= signed("00000000" & regRow1(15 downto 8));
			Bs13 <= signed("00000000" & regRow1(7 downto 0));
			Bs21 <= signed("00000000" & regRow2(23 downto 16));
			Bs23 <= signed("00000000" & regRow2(7 downto 0));
			--Bs31 <= shift_left(signed("00000000" & regRow3(23 downto 16)), 1);
			Bs31 <= signed("00000000" & regRow3(23 downto 16));
			Bs32 <= signed("00000000" & regRow3(15 downto 8));
			Bs33 <= signed("00000000" & regRow3(7 downto 0));

			State_next <= waitForInvert;

		WHEN waitForInvert =>



			--if unsigned(D1) > X"00FF" then
			--    --Row2MSB_next(7 downto 0) <= X"FF";
			--	newPixelReg_next(15 downto 8) <= X"FF";
			--elsif signed(D1) < 0 then
			--	newPixelReg_next(15 downto 8) <= X"00";
			--else
			--	--Row2MSB_next(7 downto 0) <= D1(7 downto 0);
			--	newPixelReg_next(15 downto 8) <= D1Shifted(7 downto 0);
			--end if;
--
			--if unsigned(D2) > X"00FF" then
			--	--Row2LSB_next(15 downto 8) <= X"FF";
			--	newPixelReg_next(7 downto 0) <= X"FF";
			--elsif signed(D2) < 0 then
			--	newPixelReg_next(7 downto 0) <= X"00";
			--else
			--	--Row2LSB_next(15 downto 8) <= D2(7 downto 0);
			--	newPixelReg_next(7 downto 0) <= D2Shifted(7 downto 0);
			--end if;

			newPixelReg_next(15 downto 8) <= D1Shifted(7 downto 0);
			newPixelReg_next(7 downto 0) <= D2Shifted(7 downto 0);

--			Row2MSB_next(7 downto 0) <= D1(7 downto 0);
--			Row2LSB_next(15 downto 8) <= D2(7 downto 0);

			CtrlFlag_next <= (others => '0');
			addrAcc_next <= word_t(unsigned(addrAcc) + 50686);
			State_next <= writeState;

		when writeState =>
			req <= '1';
			rw <= '0';
			--CtrlFlag_next <= std_logic_vector(unsigned(regCtrlFlag) + 1);	
				
 			--dataW(15 downto 0) <= regRow2(15 downto 8) & regRow2(23 downto 16);
 			dataW(15 downto 0) <= newPixelReg(7 downto 0) & newPixelReg(15 downto 8);
			addrAcc_next <= word_t(unsigned(addrAcc) - 50686);
			State_next <= decisionState;
			


--			if (regCtrlFlag = "000") then
--				dataW(15 downto 0) <= regRow1(23 downto 16) & regRow1(31 downto 24);
--				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
--				State_next <= writeState;
--				
--			elsif (regCtrlFlag = "001") then
--				dataW(15 downto 0) <= regRow1(7 downto 0) & regRow1(15 downto 8);
--				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
--				State_next <= writeState;
--				
--			elsif (regCtrlFlag = "010") then
-- 				dataW(15 downto 0) <= regRow2(23 downto 16) & regRow2(31 downto 24);
--				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
--				State_next <= writeState;
--				
--			elsif (regCtrlFlag = "011") then
-- 				dataW(15 downto 0) <= regRow2(7 downto 0) & regRow2(15 downto 8);
--				addrAcc_next <= word_t(unsigned(addrAcc) + 175);
--				State_next <= writeState;
--
--			elsif (regCtrlFlag = "100") then
-- 				dataW(15 downto 0) <= regRow3(23 downto 16) & regRow3(31 downto 24);
--				addrAcc_next <= word_t(unsigned(addrAcc) + 1);
--				State_next <= writeState;
--
--			elsif (regCtrlFlag = "101") then
-- 				dataW(15 downto 0) <= regRow3(7 downto 0) & regRow3(15 downto 8);
--				addrAcc_next <= word_t(unsigned(addrAcc) - 51039);
-- 				State_next <= decisionState;
--			end if;

		when decisionState =>
			if (addrAcc > IMG_ADDR_OOB) then
				finish <= '1';
				State_next <= idle;
			elsif(strideCounter = STRIDE_SIZE) then
				strideCounter_next <= (others => '0');
				CtrlFlag_next <= (others => '0');
				State_next <= readStateMSB;
			else
				Row1MSB_next <= regRow1(15 downto 0);
				Row2MSB_next <= regRow2(15 downto 0);
				Row3MSB_next <= regRow3(15 downto 0);

				State_next <= readStateLSB;
				CtrlFlag_next <= (others => '0');
			end if ;

	END CASE;
END PROCESS control_loop;



--sub1 <= As13 - As11;
--sub2 <= As23 - As21;
--sub3 <= As33 - As31;
--sub4 <= As11 - As31;
--sub5 <= Bs12 - Bs32;
--sub6 <= As13 - As33;
--
Aadd1 <= shift_left((As23 - As21), 1);
Aadd2 <= shift_left((As12 - As32), 1);
Badd1 <= shift_left((Bs23 - Bs21), 1);
Badd2 <= shift_left((Bs12 - Bs32), 1);

--D1 <= halfword_t( abs(Aadd1) + abs(Aadd2) );
--D1 <= halfword_t( abs(As13 - As11 + (As23 - As21) + As33 - As31) + abs(As11 - As31 + (As12 - As32) + As13 - As33) );
D1 <= halfword_t( abs(As13 - As11 + Aadd1 + As33 - As31) + abs(As11 - As31 + Aadd2 + As13 - As33) );
D2 <= halfword_t( abs(Bs13 - Bs11 + Badd1 + Bs33 - Bs31) + abs(Bs11 - Bs31 + Badd2 + Bs13 - Bs33) );
--D1 <= byte_t(As13 - As11);
--D2 <= byte_t(Bs13 - Bs11);
D1Shifted <= halfword_t(shift_right(signed(D1), 3));
D2Shifted <= halfword_t(shift_right(signed(D2), 3));

--Template for a process
myprocess: process(clk,reset)
begin
  if reset = '1' then
		addrAcc <= (others => '0');
		currState <= idle;
		strideCounter <= (others => '0');
		regRow1 <= (others => '0');
		regRow2 <= (others => '0');
		regRow3 <= (others => '0');
		regCtrlFlag <= (others => '0');
  elsif rising_edge(clk) then
		addrAcc <= addrAcc_next;
		currState <= State_next;
		strideCounter <= strideCounter_next;

		regRow1(31 downto 0) <= Row1MSB_next & Row1LSB_next;
		regRow2(31 downto 0) <= Row2MSB_next & Row2LSB_next;
		regRow3(31 downto 0) <= Row3MSB_next & Row3LSB_next;
		newPixelReg <= newPixelReg_next;

		regCtrlFlag <= CtrlFlag_next;
  end if;
end process myprocess;

END structure;



