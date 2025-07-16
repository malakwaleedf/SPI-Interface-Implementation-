module singleport_async_ram (din, clk, rst_n, rx_valid, dout, tx_valid);
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;
input [9:0] din;
input clk, rst_n, rx_valid;
output reg [7:0] dout;
output reg tx_valid;

reg [7:0] mem [MEM_DEPTH-1 : 0];
reg [ADDR_SIZE-1 : 0] addr;

always @(posedge clk) begin
    if(!rst_n) begin
        dout <= 0;
        tx_valid <= 0;
        addr <= 0;
    end
    else begin
        if(din[9:8] === 2'b00 && rx_valid) begin
            addr <= din[7:0];
            tx_valid <= 0;
        end
        else if(din[9:8] === 2'b01 && rx_valid) begin
            mem[addr] <= din[7:0];
            tx_valid <= 0;
        end
        else if(din[9:8] === 2'b10 && rx_valid) begin
            addr <= din[7:0];
            tx_valid <= 0;
        end
        else if(din[9:8] === 2'b11) begin
            dout <= mem[addr];
            tx_valid <= 1;
        end
    end
end
    
endmodule