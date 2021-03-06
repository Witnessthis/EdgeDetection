-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - tL_sk 2.
--             :
--  Developers :  JonL_s Benjamin Borch - init52435@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be build  
--             :  in tL_sk two of the Edge Detection design project. It contains an     
--             :  architecture skeleton for the entity L_s well.                
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
-- The entity for tL_sk two. Notice the additional signals for the memory.        
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
end acc;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture structure OF acc IS

-- All internal signals are defined here
-- MaxAddr = ((352*288)/2)-1 = 50687
-- StartWriteAddress = 50688
type state_type IS (idle_state, read_left_buffer_state, read_right_buffer_state, decision_state);

constant IMG_ADDR_OOB : word_t := word_t(to_unsigned(50336, 32));
constant SOURCE_ADDRESS_SPACE_OFFSET : unsigned := to_unsigned(50686, 32);
constant RESULT_ADDRESS_SPACE_OFFSET : unsigned := to_unsigned(50335, 32);
constant STRIDE_SIZE : byte_t := byte_t(to_unsigned(175, 8));

signal address_pointer, address_pointer_next : word_t;
signal state, state_next : state_type;
signal top_buff_reg, middle_buff_reg, bottom_buff_reg : word_t;
signal top_buff_reg_next, middle_buff_reg_next, bottom_buff_reg_next : word_t;
signal ctrl_flag_reg, ctrl_flag_reg_next : std_logic_vector(1 downto 0);
signal stride_counter, stride_counter_next : byte_t;
signal sobel_pixel_left, sobel_pixel_right, sobel_pixel_left_shifted, sobel_pixel_right_shifted : halfword_t;
signal L_s11, L_s12, L_s13, L_s21, L_s23, L_s31, L_s32, L_s33, R_s11, R_s12, R_s13, R_s21, R_s23, R_s31, R_s32, R_s33 : signed(15 downto 0);
signal Aadd1, Aadd2, Badd1, Badd2 :signed(15 downto 0);
BEGIN

control_loop : process(state, start, address_pointer, ctrl_flag_reg, top_buff_reg, middle_buff_reg, bottom_buff_reg, dataR, stride_counter, stride_counter_next, sobel_pixel_left_shifted, sobel_pixel_right_shifted, address_pointer_next)
BEGIN
	
	finish <= '0';
	req <= '0';
	rw <= '0';
	dataW <= (others => '0');

	stride_counter_next <= stride_counter;
	addr <= address_pointer;
	state_next <= idle_state;
	address_pointer_next <= address_pointer;
	ctrl_flag_reg_next <= ctrl_flag_reg;

	top_buff_reg_next(31 downto 16) <= top_buff_reg(31 downto 16);
	top_buff_reg_next(15 downto 0) <= top_buff_reg(15 downto 0);

	middle_buff_reg_next(31 downto 16) <= middle_buff_reg(31 downto 16);
	middle_buff_reg_next(15 downto 0) <= middle_buff_reg(15 downto 0);

	bottom_buff_reg_next(31 downto 16) <= bottom_buff_reg(31 downto 16);
	bottom_buff_reg_next(15 downto 0) <= bottom_buff_reg(15 downto 0);

	L_s11 <= signed("00000000" & top_buff_reg(31 downto 24)); 
	L_s12 <= signed("00000000" & top_buff_reg(23 downto 16)); 
	L_s13 <= signed("00000000" & top_buff_reg(15 downto 8)); 
	L_s21 <= signed("00000000" & middle_buff_reg(31 downto 24));
	L_s23 <= signed("00000000" & middle_buff_reg(15 downto 8)); 
	L_s31 <= signed("00000000" & bottom_buff_reg(31 downto 24)); 
	L_s32 <= signed("00000000" & bottom_buff_reg(23 downto 16)); 
	L_s33 <= signed("00000000" & bottom_buff_reg(15 downto 8));

	R_s11 <= signed("00000000" & top_buff_reg(23 downto 16));
	R_s12 <= signed("00000000" & top_buff_reg(15 downto 8));
	R_s13 <= signed("00000000" & top_buff_reg(7 downto 0));
	R_s21 <= signed("00000000" & middle_buff_reg(23 downto 16));
	R_s23 <= signed("00000000" & middle_buff_reg(7 downto 0));
	R_s31 <= signed("00000000" & bottom_buff_reg(23 downto 16));
	R_s32 <= signed("00000000" & bottom_buff_reg(15 downto 8));
	R_s33 <= signed("00000000" & bottom_buff_reg(7 downto 0));
	
	case (state) IS
		-- waits for the start signal to be asserted high
		when idle_state =>
			address_pointer_next <= (others => '0');
			ctrl_flag_reg_next <= (others => '0');
			if start = '1' then  
				state_next <= read_left_buffer_state;
			else
				state_next <= idle_state;
			end if;

		-- read data from dataR into the MSBs of the buffer registers
		when read_left_buffer_state =>
			req <= '1';
			rw <= '1';
			ctrl_flag_reg_next <= std_logic_vector(unsigned(ctrl_flag_reg) + 1);
			address_pointer_next <= word_t(unsigned(address_pointer) + 176);
			state_next <= read_left_buffer_state;

			if (ctrl_flag_reg = "00") then
				top_buff_reg_next(31 downto 16) <= dataR(7 downto 0) & dataR(15 downto 8);
			elsif (ctrl_flag_reg = "01") then
				middle_buff_reg_next(31 downto 16) <= dataR(7 downto 0) & dataR(15 downto 8);	
			else
				bottom_buff_reg_next(31 downto 16) <= dataR(7 downto 0) & dataR(15 downto 8);
			-- restore the address_pointer to the address of the pixel pair
			-- neighboring the pixels in top_buff_reg (i.e. the address next to it)
				address_pointer_next <= word_t(unsigned(address_pointer) - 351);
				state_next <= read_right_buffer_state;
				ctrl_flag_reg_next <= (others => '0');

			end if;

		-- read data from dataR into the LSBs of the buffer registers
		when read_right_buffer_state =>
			req <= '1';
			rw <= '1';
			ctrl_flag_reg_next <= std_logic_vector(unsigned(ctrl_flag_reg) + 1);
			address_pointer_next <= word_t(unsigned(address_pointer) + 176);
			state_next <= read_right_buffer_state;
			
			if (ctrl_flag_reg = "00") then
				top_buff_reg_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
			elsif (ctrl_flag_reg = "01") then
				middle_buff_reg_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
			else
				bottom_buff_reg_next(15 downto 0) <= dataR(7 downto 0) & dataR(15 downto 8);
				-- set the address_pointer to hold the address of the destination region in RAM
				address_pointer_next <= word_t(unsigned(address_pointer) + RESULT_ADDRESS_SPACE_OFFSET);
				state_next <= decision_state;
				ctrl_flag_reg_next <= (others => '0');
				stride_counter_next <= byte_t(unsigned(stride_counter)+1);
			end if;

		when decision_state =>

			req <= '1';
			rw <= '0';
						
 			dataW(15 downto 0) <= sobel_pixel_right_shifted(7 downto 0) & sobel_pixel_left_shifted(7 downto 0	);
			address_pointer_next <= word_t(unsigned(address_pointer) - SOURCE_ADDRESS_SPACE_OFFSET);

			if (address_pointer_next = IMG_ADDR_OOB) then
				finish <= '1';
				state_next <= decision_state;
				if (start='0') then
					state_next <= idle_state;
				end if;
			elsif(stride_counter = STRIDE_SIZE) then
				stride_counter_next <= (others => '0');
				state_next <= read_left_buffer_state;
			else
				top_buff_reg_next(31 downto 16) <= top_buff_reg(15 downto 0);
				middle_buff_reg_next(31 downto 16) <= middle_buff_reg(15 downto 0);
				bottom_buff_reg_next(31 downto 16) <= bottom_buff_reg(15 downto 0);
				state_next <= read_right_buffer_state;
			end if ;

	end case;
end process control_loop;

Aadd1 <= shift_left((L_s23 - L_s21), 1);
Aadd2 <= shift_left((L_s12 - L_s32), 1);
Badd1 <= shift_left((R_s23 - R_s21), 1);
Badd2 <= shift_left((R_s12 - R_s32), 1);


sobel_pixel_left <= halfword_t( abs(L_s13 - L_s11 + Aadd1 + L_s33 - L_s31) + abs(L_s11 - L_s31 + Aadd2 + L_s13 - L_s33) );
sobel_pixel_right <= halfword_t( abs(R_s13 - R_s11 + Badd1 + R_s33 - R_s31) + abs(R_s11 - R_s31 + Badd2 + R_s13 - R_s33) );

sobel_pixel_left_shifted <= halfword_t(shift_right(signed(sobel_pixel_left), 3));
sobel_pixel_right_shifted <= halfword_t(shift_right(signed(sobel_pixel_right), 3));

myprocess: process(clk,reset)
begin
  if reset = '1' then
		address_pointer <= (others => '0');
		state <= idle_state;
		stride_counter <= (others => '0');
		ctrl_flag_reg <= (others => '0');
		
		top_buff_reg <= (others => '0');
		middle_buff_reg <= (others => '0');
		bottom_buff_reg <= (others => '0');
  elsif rising_edge(clk) then
		address_pointer <= address_pointer_next;
		state <= state_next;
		stride_counter <= stride_counter_next;
		ctrl_flag_reg <= ctrl_flag_reg_next;
		
		top_buff_reg <= top_buff_reg_next;
		middle_buff_reg <= middle_buff_reg_next;
		bottom_buff_reg <= bottom_buff_reg_next;
  end if;
end process myprocess;

end structure;