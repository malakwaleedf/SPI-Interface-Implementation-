module singleport_async_ram_tb;
    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;
    reg [9:0] din;
    reg rx_valid, clk, rst_n;
    wire [7:0] dout;
    wire tx_valid;

    integer i;

    singleport_async_ram dut (din, clk, rst_n, rx_valid, dout, tx_valid);

    initial begin
        clk = 1;
        forever begin
            #2 clk = ~clk;
        end
    end
    initial begin
        for(i = 0; i<MEM_DEPTH; i = i+1) begin
            dut.mem[i] = 0;
        end
        $writememh("mem.dat", dut.mem);
        rst_n = 0;
        rx_valid = 0;
        din = 0;
        @(negedge clk);
        rst_n = 1;
        // direct testing 
        // hold write address
        din[9:8] = 2'b00;
        din[7:0] = 8'h0a; // address to write to
        rx_valid = 1;
        @(negedge clk);
        // write to mem
        din[9:8] = 2'b01;
        din[7:0] = 8'hf5; // data to written
        @(negedge clk);
        $writememh("mem.dat", dut.mem);
        $readmemh("mem.dat", dut.mem);
         // hold read address
        din[9:8] = 2'b10;
        din[7:0] = 8'h0a; // address to read from (same address as write)
        rx_valid = 1;
        @(negedge clk);
        // read from mem
        din[9:8] = 2'b11;
        din[7:0] = 8'h55; // dummy data
        @(negedge clk);
        if(dout !== 8'hf5) begin
            $display("Error dout= %H", dout);
            $stop;
        end
        // random testing 
        din[9] = 0; // test write command 
        repeat(1000) begin
            din[8:0] = $random;
            rx_valid = $random;
            @(negedge clk);
        end
        din[9] = 1; // test read command 
        repeat(1000) begin
            din[8:0] = $random;
            rx_valid = $random;
            @(negedge clk);
        end
        // test write and read commands together
        repeat(1000) begin
            din[9:0] = $random;
            rx_valid = $random;
            @(negedge clk);
        end
        $writememh("mem.dat", dut.mem);
        $stop;
    end
    initial
        $monitor("rst_n= %b, din[9:8]= %b, din[7:0]= %b, rx_valid= %b, dout= %b, tx_valid= %b", rst_n, din[9:8], din[7:0], rx_valid, dout, tx_valid);

endmodule