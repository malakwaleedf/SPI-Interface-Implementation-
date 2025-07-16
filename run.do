vlib work
vlog ram.v ram_tb.v spi_slave.v top.v master_tb.v
vsim -voptargs=+acc work.master_tb
add wave *
add wave -position insertpoint  \
sim:/master_tb/dut/spi_slave_interface/rx_data
run -all
#quit -sim