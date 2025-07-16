`timescale 1ns/1ns
module master_tb;
reg MOSI, SS_n, rst_n, clk;
wire MISO;

reg [7:0] read_data;
reg [7:0] address;
reg [7:0] data;

integer i;

spi_wrapper dut(MISO, MOSI, SS_n, rst_n, clk);

initial begin
    clk = 1;
    forever begin
        #5 clk = ~clk; // 10 ns clk period
    end
end

initial begin
    address = 8'b1000_0000; // address to be used
    data = 8'h55; // data to be used
    i = 0;
    read_data = 0;
    rst_n = 0; // reset design
    MOSI = 0;
    SS_n = 0;
    @(negedge clk);
    // reset 
    if(MISO !== 0) begin
        $display("error design is not reset, MISO = %0H", MISO);
        $stop;
    end
    // write address 
    rst_n = 1;
    SS_n = 0;
    MOSI = 0;
    @(negedge clk);
    @(negedge clk); // wait 2 clk cycles to be in WRITE state
    MOSI = 0;
    @(negedge clk);
    MOSI = 0; // first 2 bits are 2'b00 to activate the write address command in the RAM
    @(negedge clk);
    for (i = 7; i >= 0; i = i - 1) begin
        MOSI = address[i];
        @(negedge clk);
    end
    if(dut.spi_slave_interface.rx_data !== {2'b00, address}) begin
        $display("error address is not written, address = %0b", dut.spi_slave_interface.rx_data);
        $stop;
    end
    // write data
    MOSI = 0;
    @(negedge clk);
    MOSI = 1; // first 2 bits are 2'b01 to activate the write data command in the RAM
    @(negedge clk);
    for (i = 7; i >= 0; i = i - 1) begin
        MOSI = data[i];
        @(negedge clk);
    end
    if(dut.spi_slave_interface.rx_data !== {2'b01, data}) begin
        $display("error data is not written, data = %0b", dut.spi_slave_interface.rx_data);
        $stop;
    end
    SS_n = 1; // back to IDLE state
    @(negedge clk);
    // read address
    SS_n = 0;
    MOSI = 1;
    @(negedge clk);
    @(negedge clk); // wait 2 clk cycles to be in READ_ADD state
    MOSI = 1;
    @(negedge clk);
    MOSI = 0; // first 2 bits are 2'b10 to activate the read address command in the RAM
    @(negedge clk);
    for (i = 7; i >= 0; i = i - 1) begin
        MOSI = address[i];
        @(negedge clk);
    end
    if(dut.spi_slave_interface.rx_data !== {2'b10, address}) begin
        $display("error address is not written for read operation, address = %0b", dut.spi_slave_interface.rx_data);
        $stop;
    end
    SS_n = 1; // back to IDLE state
    @(negedge clk);
    // read data
    SS_n = 0;
    MOSI = 1;
    @(negedge clk);
    @(negedge clk); // wait 2 clk cycles to be in READ_DATA state
    MOSI = 1;
    @(negedge clk);
    MOSI = 1; // first 2 bits are 2'b11 to activate the read data command in the RAM
    @(negedge clk);
    for (i = 7; i >= 0; i = i - 1) begin
        MOSI = address[i];
        @(negedge clk);
    end //dummy data
    for (i = 7; i >= 0; i = i - 1) begin
        read_data[i] = MISO;
        @(negedge clk);
    end 
    if(read_data !== data) begin
        $display("error the read data = %0H", read_data);
        $stop;
    end
    $display("Tests passed");
    $stop;
end

endmodule