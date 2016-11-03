
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
add wave -label clk				/testbench/clk
add wave -label reset			/testbench/reset
add wave -label addr			/testbench/addr
add wave -label dataR			/testbench/dataR
add wave -label dataW			/testbench/dataW
add wave -label req				/testbench/req
add wave -label rw				/testbench/rw
add wave -label start			/testbench/start
add wave -label finish			/testbench/finish
add wave -label Row1MSB_next 	/testbench/Accelerator/Row1MSB_next
add wave -label Row1LSB_next 	/testbench/Accelerator/Row1LSB_next
add wave -label regRow1 		/testbench/Accelerator/regRow1
add wave -label Row2MSB_next 	/testbench/Accelerator/Row2MSB_next
add wave -label Row2LSB_next 	/testbench/Accelerator/Row2LSB_next
add wave -label regRow2 		/testbench/Accelerator/regRow2
add wave -label Row3MSB_next 	/testbench/Accelerator/Row3MSB_next
add wave -label Row3LSB_next 	/testbench/Accelerator/Row3LSB_next
add wave -label regRow3 		/testbench/Accelerator/regRow3
add wave -label addrAcc 		/testbench/Accelerator/addrAcc
add wave -label addrAcc_next 	/testbench/Accelerator/addrAcc_next
add wave -label State_next 		/testbench/Accelerator/State_next
add wave -label currState 		/testbench/Accelerator/currState

run 3000ms

# WaveRestoreZoom changes the wave view to show the simulated time
WaveRestoreZoom {0 ns} {3000 ns}