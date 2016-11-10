
## ##############################################################
##
##	Title		: Compilation and simulation
##
##	Developers	: Jens Spars� and Rasmus Bo S�rensen
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
add wave -group frame_signals -color #93e1d8 -label Row1MSB_next 	/testbench/Accelerator/Row1MSB_next
add wave -group frame_signals -color #93e1d8 -label Row1LSB_next 	/testbench/Accelerator/Row1LSB_next
add wave -group frame_signals -color #93e1d8 -label regRow1 		/testbench/Accelerator/regRow1

add wave -group frame_signals -divider frame_row_2
add wave -group frame_signals -color #6c6ea0 -label Row2MSB_next 	/testbench/Accelerator/Row2MSB_next
add wave -group frame_signals -color #6c6ea0 -label Row2LSB_next 	/testbench/Accelerator/Row2LSB_next
add wave -group frame_signals -color #6c6ea0 -label regRow2 		/testbench/Accelerator/regRow2

add wave -group frame_signals -divider frame_row_3
add wave -group frame_signals -color #fed766 -label Row3MSB_next 	/testbench/Accelerator/Row3MSB_next
add wave -group frame_signals -color #fed766 -label Row3LSB_next 	/testbench/Accelerator/Row3LSB_next
add wave -group frame_signals -color #fed766 -label regRow3 		/testbench/Accelerator/regRow3

add wave -group frame_signals -divider addresses
add wave -group frame_signals -decimal -label addrAcc 		/testbench/Accelerator/addrAcc
add wave -group frame_signals -decimal -label addrAcc_next 	/testbench/Accelerator/addrAcc_next

add wave -group frame_signals -divider states
add wave -group frame_signals -label currState 	/testbench/Accelerator/currState
add wave -group frame_signals -label State_next	/testbench/Accelerator/State_next

add wave -divider TempGroup
add wave -label strideCounter 	/testbench/Accelerator/strideCounter
add wave -label strideCounter_next	/testbench/Accelerator/strideCounter_next

run 3000ms

# WaveRestoreZoom changes the wave view to show the simulated time
WaveRestoreZoom {0 ns} {3000 ns}