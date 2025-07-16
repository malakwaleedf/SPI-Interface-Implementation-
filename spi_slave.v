module spi_slave (clk, rst_n, tx_data, tx_valid, rx_data, rx_valid, SS_n, MISO, MOSI);
parameter IDLE = 3'b000;
parameter WRITE = 3'b001;
parameter CHK_CMD = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;
input clk, rst_n, tx_valid, SS_n, MOSI;
input [7:0] tx_data;
output reg rx_valid, MISO;
output reg [9:0] rx_data;

(*fsm_encoding = "one_hot"*)
reg [2:0] cs, ns;
reg addr_b4_data; // internal sig to make sure READ_ADD state comes before READ_DATA to ensure having address to be read from
reg received; // internal sig to make sure data is received from RAM
reg [3:0] serial_to_parallel_count;
reg [2:0] parallel_to_serial_count;
reg [7:0] data_received; // internal bus to hold data received from RAM

always @(posedge clk) begin
    if(!rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

always @(*) begin
    case (cs)
    IDLE: begin
        if(SS_n) begin
            ns = IDLE;
        end
        else begin
            ns = CHK_CMD;
        end
    end
    CHK_CMD: begin
        if(SS_n) begin
            ns = IDLE;
        end
        else begin
            if(!MOSI) begin
                ns = WRITE;
            end
            else begin
                if(!addr_b4_data) begin
                    ns = READ_ADD;
                end
                else begin
                    ns = READ_DATA;
                end
            end
        end
    end
    WRITE: begin
        if(SS_n) begin
            ns = IDLE;
        end
        else begin
            ns = WRITE;
        end
    end
    READ_ADD: begin
        if(SS_n) begin
            ns = IDLE;
        end
        else begin
            ns = READ_ADD;
        end
    end
    READ_DATA: begin
        if(SS_n) begin
            ns = IDLE;
        end
        else begin
            ns = READ_DATA;
        end
    end
    default: ns = IDLE;
    endcase
end

always @(posedge clk) begin
   if(!rst_n) begin // reset all outputs and internal signals 
    addr_b4_data <= 0;
    received <= 0;
    MISO <= 0;
    rx_data <= 0;
    rx_valid <= 0; 
    serial_to_parallel_count <= 0;
    parallel_to_serial_count <= 0;
    data_received <= 0;
   end
   else begin
    case (cs)
    IDLE: begin
        MISO <= 0;
        rx_valid <= 0; 
        received <= 0;
        serial_to_parallel_count <= 0;
        parallel_to_serial_count <= 0;
    end
    CHK_CMD: begin
        MISO <= 0;
        rx_valid <= 0; 
        serial_to_parallel_count <= 0;
        parallel_to_serial_count <= 0;
    end
    WRITE: begin // serial data in written to the rx_data outport after 10 clk cycles 
        rx_data[9 - serial_to_parallel_count] <= MOSI;
        serial_to_parallel_count = serial_to_parallel_count + 1;
        if(serial_to_parallel_count === 10) begin
            rx_valid <= 1;
            serial_to_parallel_count <= 0;
        end
    end
    READ_ADD: begin
        rx_data[9 - serial_to_parallel_count] <= MOSI;
        serial_to_parallel_count = serial_to_parallel_count + 1;
        if(serial_to_parallel_count === 10) begin
            rx_valid <= 1;
            serial_to_parallel_count <= 0;
        end
        addr_b4_data <= 1;
    end
    READ_DATA: begin
        rx_data[9 - serial_to_parallel_count] <= MOSI;
        serial_to_parallel_count = serial_to_parallel_count + 1;
        if(serial_to_parallel_count === 10) begin
            rx_valid <= 1;
            serial_to_parallel_count <= 0;
        end
        if(tx_valid) begin
            data_received <= tx_data;
            if(serial_to_parallel_count === 9)
                received <= 1;
        end
        if(received) begin
            MISO <= data_received [7 - parallel_to_serial_count];
            parallel_to_serial_count = parallel_to_serial_count + 1;
            if(parallel_to_serial_count === 8) begin
                received <= 0;
                parallel_to_serial_count <= 0;
            end
        end
        addr_b4_data <= 0;
    end
    default: begin
        addr_b4_data <= 0;
        received <= 0;
        MISO <= 0;
        rx_data <= 0;
        rx_valid <= 0; 
        serial_to_parallel_count <= 0;
        parallel_to_serial_count <= 0;
    end
    endcase
   end
end
    
endmodule