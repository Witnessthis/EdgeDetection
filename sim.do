
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
add wave -label inPixReg 		/testbench/Accelerator/inPixReg
#add wave -label inPixReg_next 	/testbench/Accelerator/inPixReg_next
add wave -label outPixReg 		/testbench/Accelerator/outPixReg
#add wave -label outPixReg_next /testbench/Accelerator/outPixReg_next
add wave -label addrAcc 		/testbench/Accelerator/addrAcc
#add wave -label addrAcc_next 	/testbench/Accelerator/addrAcc_next
add wave -label s_state 		/testbench/Accelerator/s_state
#add wave -label s_next_state 	/testbench/Accelerator/s_next_state

run 3000ms

# WaveRestoreZoom changes the wave view to show the simulated time
WaveRestoreZoom {0 ns} {3000 ns}