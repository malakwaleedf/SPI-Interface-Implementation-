module spi_wrapper (MISO, MOSI, SS_n, rst_n, clk);
input MOSI, SS_n, rst_n, clk;
output MISO;

wire [9:0] slave_out;
wire [7:0] ram_out;
wire rx_valid, tx_valid;

spi_slave spi_slave_interface(clk, rst_n, ram_out, tx_valid, slave_out, rx_valid, SS_n, MISO, MOSI);
singleport_async_ram spi_ram(slave_out, clk, rst_n, rx_valid, ram_out, tx_valid);

endmodule