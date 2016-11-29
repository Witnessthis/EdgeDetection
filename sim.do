
## ##############################################################
##
##	Title		: Compilation and simulation
##
##	Developers	: Jens Sparsø and Rasmus Bo Sørensen
##
##	Revision	: 02203 fall 2012 v.2
##
## This script is meant for setting up the simulation
## of the project
#################################################################

# add wave will add the waves to the wave view
# To change the name of the waves in the wave view use the -label option
# Example:
# add wave -label clk /testbench/clk

view wave

add wave -label clk	/testbench/clk

add wave -group testbench_signals -label reset	/testbench/reset
add wave -group testbench_signals -label start	/testbench/start
add wave -group testbench_signals -label finish	/testbench/finish

add wave -group ram_dataR -label dataR		 /testbench/dataR
add wave -group ram_dataW -label dataW		 /testbench/dataW

add wave -group ram_signals -decimal -label addr /testbench/addr
add wave -group ram_signals -label req			 /testbench/req
add wave -group ram_signals -label rw			 /testbench/rw

add wave -group frame_signals -divider frame_row_1
add wave -group frame_signals -color #93e1d8 -label top_left_buff_reg_next 	/testbench/Accelerator/top_left_buff_reg_next
add wave -group frame_signals -color #93e1d8 -label top_right_buff_reg_next /testbench/Accelerator/top_right_buff_reg_next
add wave -group frame_signals -color #93e1d8 -label top_buff_reg 			/testbench/Accelerator/top_buff_reg

add wave -group frame_signals -divider frame_row_2
add wave -group frame_signals -color #6c6ea0 -label middle_left_buff_reg_next	/testbench/Accelerator/middle_left_buff_reg_next
add wave -group frame_signals -color #6c6ea0 -label middle_right_buff_reg_next	/testbench/Accelerator/middle_right_buff_reg_next
add wave -group frame_signals -color #6c6ea0 -label middle_buff_reg 			/testbench/Accelerator/middle_buff_reg

add wave -group frame_signals -divider frame_row_3
add wave -group frame_signals -color #fed766 -label bottom_left_buff_reg_next	/testbench/Accelerator/bottom_left_buff_reg_next
add wave -group frame_signals -color #fed766 -label bottom_right_buff_reg_next	/testbench/Accelerator/bottom_right_buff_reg_next
add wave -group frame_signals -color #fed766 -label bottom_buff_reg 			/testbench/Accelerator/bottom_buff_reg

add wave -group frame_signals -divider addresses
add wave -group frame_signals -decimal -label address_pointer 		/testbench/Accelerator/address_pointer
add wave -group frame_signals -decimal -label address_pointer_next 	/testbench/Accelerator/address_pointer_next

add wave -group frame_signals -divider states
add wave -group frame_signals -label state 		/testbench/Accelerator/state
add wave -group frame_signals -label state_next	/testbench/Accelerator/state_next

add wave -group sobel_signals 
add wave -group sobel_signals -divider As_Signals
add wave -group sobel_signals -label L_s11   /testbench/Accelerator/L_s11
add wave -group sobel_signals -label L_s12   /testbench/Accelerator/L_s12
add wave -group sobel_signals -label L_s13   /testbench/Accelerator/L_s13
add wave -group sobel_signals -label L_s21   /testbench/Accelerator/L_s21
add wave -group sobel_signals -label L_s23   /testbench/Accelerator/L_s23
add wave -group sobel_signals -label L_s31   /testbench/Accelerator/L_s31
add wave -group sobel_signals -label L_s32   /testbench/Accelerator/L_s32
add wave -group sobel_signals -label L_s33   /testbench/Accelerator/L_s33

add wave -group sobel_signals -divider Bs_Signals
add wave -group sobel_signals -label R_s11   /testbench/Accelerator/R_s11
add wave -group sobel_signals -label R_s12   /testbench/Accelerator/R_s12
add wave -group sobel_signals -label R_s13   /testbench/Accelerator/R_s13
add wave -group sobel_signals -label R_s21   /testbench/Accelerator/R_s21
add wave -group sobel_signals -label R_s23   /testbench/Accelerator/R_s23
add wave -group sobel_signals -label R_s31   /testbench/Accelerator/R_s31
add wave -group sobel_signals -label R_s32   /testbench/Accelerator/R_s32
add wave -group sobel_signals -label R_s33   /testbench/Accelerator/R_s33

add wave -group sobel_signals -divider THE_D
add wave -group sobel_signals -label sobel_pixel_left   /testbench/Accelerator/sobel_pixel_left
add wave -group sobel_signals -label sobel_pixel_right   /testbench/Accelerator/sobel_pixel_right

add wave -group sobel_signals -divider intermediate
add wave -group sobel_signals -label Aadd1   /testbench/Accelerator/Aadd1
add wave -group sobel_signals -label Aadd2   /testbench/Accelerator/Aadd2
add wave -group sobel_signals -label Badd1   /testbench/Accelerator/Badd1
add wave -group sobel_signals -label Badd2   /testbench/Accelerator/Badd2

run 3000ms

# WaveRestoreZoom changes the wave view to show the simulated time
WaveRestoreZoom {0 ns} {3000 ns}