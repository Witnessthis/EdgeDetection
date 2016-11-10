
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

add wave -group sobel_signals 
add wave -group sobel_signals -divider As_Signals
add wave -group sobel_signals -label As11   /testbench/Accelerator/As11
add wave -group sobel_signals -label As12   /testbench/Accelerator/As12
add wave -group sobel_signals -label As13   /testbench/Accelerator/As13
add wave -group sobel_signals -label As21   /testbench/Accelerator/As21
add wave -group sobel_signals -label As23   /testbench/Accelerator/As23
add wave -group sobel_signals -label As31   /testbench/Accelerator/As31
add wave -group sobel_signals -label As32   /testbench/Accelerator/As32
add wave -group sobel_signals -label As33   /testbench/Accelerator/As33
add wave -group sobel_signals -divider Bs_Signals
add wave -group sobel_signals -label Bs11   /testbench/Accelerator/Bs11
add wave -group sobel_signals -label Bs12   /testbench/Accelerator/Bs12
add wave -group sobel_signals -label Bs13   /testbench/Accelerator/Bs13
add wave -group sobel_signals -label Bs21   /testbench/Accelerator/Bs21
add wave -group sobel_signals -label Bs23   /testbench/Accelerator/Bs23
add wave -group sobel_signals -label Bs31   /testbench/Accelerator/Bs31
add wave -group sobel_signals -label Bs32   /testbench/Accelerator/Bs32
add wave -group sobel_signals -label Bs33   /testbench/Accelerator/Bs33
add wave -group sobel_signals -divider THE_D
add wave -group sobel_signals -label D1   /testbench/Accelerator/D1
add wave -group sobel_signals -label D2   /testbench/Accelerator/D2
add wave -group sobel_signals -divider intermediate
add wave -group sobel_signals -label sub1   /testbench/Accelerator/sub1
add wave -group sobel_signals -label sub2   /testbench/Accelerator/sub2
add wave -group sobel_signals -label sub3   /testbench/Accelerator/sub3
add wave -group sobel_signals -label sub4   /testbench/Accelerator/sub4
add wave -group sobel_signals -label sub5   /testbench/Accelerator/sub5
add wave -group sobel_signals -label sub6   /testbench/Accelerator/sub6
add wave -group sobel_signals -label add1   /testbench/Accelerator/add1
add wave -group sobel_signals -label add2   /testbench/Accelerator/add2

add wave -divider TempGroup
add wave -label strideCounter 	/testbench/Accelerator/strideCounter
add wave -label strideCounter_next	/testbench/Accelerator/strideCounter_next

run 3000ms

# WaveRestoreZoom changes the wave view to show the simulated time
WaveRestoreZoom {0 ns} {3000 ns}