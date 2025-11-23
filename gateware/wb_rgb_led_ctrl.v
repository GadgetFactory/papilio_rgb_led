// Wishbone Slave Wrapper and WS2812B controller (copied)

module wb_rgb_led_ctrl #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Clock and Reset
    input wire clk,
    input wire rst,
    
    // Wishbone Slave Interface
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire wb_we_i,
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [3:0] wb_sel_i,
    
    // RGB LED Output
    output wire led_out
);

    // Register map
    reg [23:0] led0_data;
    reg start;
    wire busy;
    
    // Address decode
    wire addr_ctrl = (wb_adr_i[7:0] == 8'h00);
    wire addr_led0 = (wb_adr_i[7:0] == 8'h04);
    
    // Wishbone read/write with simple logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'h0;
            start <= 1'b0;
            led0_data <= 24'h000000;  
        end else begin
            wb_ack_o <= 1'b0;
            start <= 1'b0;
            
            if (wb_cyc_i && wb_stb_i) begin
                wb_ack_o <= 1'b1;
                
                if (wb_we_i) begin
                    // Write
                    if (addr_ctrl) begin
                        start <= wb_dat_i[0];
                    end else if (addr_led0) begin
                        led0_data <= wb_dat_i[23:0];
                    end
                end else begin
                    // Read
                    if (addr_ctrl) begin
                        wb_dat_o <= {30'h0, busy, 1'b0};
                    end else if (addr_led0) begin
                        wb_dat_o <= {8'h0, led0_data};
                    end else begin
                        wb_dat_o <= 32'h0;
                    end
                end
            end
        end
    end
    
    // WS2812B controller
    ws2812b_controller #(
        .CLOCK_FREQ(27000000)
    ) ws2812b_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .busy(busy),
        .led_data(led0_data),
        .led_out(led_out)
    );

endmodule


// WS2812B LED Controller
module ws2812b_controller #(
    parameter CLOCK_FREQ = 27000000
)(
    input wire clk,
    input wire rst,
    input wire start,
    output reg busy,
    input wire [23:0] led_data,
    output reg led_out
);

    localparam CYCLES_PER_BIT = CLOCK_FREQ / 800000;
    localparam CYCLES_T0H = (CLOCK_FREQ * 4) / 10000000;  
    localparam CYCLES_T1H = (CLOCK_FREQ * 8) / 10000000;  
    
    reg [15:0] cycle_counter;
    reg [4:0] bit_index;
    reg current_bit;
    
    localparam IDLE = 0;
    localparam SEND_BIT = 1;
    localparam RESET = 2;
    
    reg [1:0] state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            busy <= 1'b0;
            led_out <= 1'b0;
            cycle_counter <= 0;
            bit_index <= 0;
            current_bit <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    led_out <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        state <= SEND_BIT;
                        cycle_counter <= 0;
                        bit_index <= 23;  
                        current_bit <= led_data[23];
                    end
                end
                
                SEND_BIT: begin
                    if (cycle_counter == 0) begin
                        led_out <= 1'b1;
                        current_bit <= led_data[bit_index];
                    end else if (cycle_counter == CYCLES_T0H && !current_bit) begin
                        led_out <= 1'b0;
                    end else if (cycle_counter == CYCLES_T1H && current_bit) begin
                        led_out <= 1'b0;
                    end
                    
                    if (cycle_counter >= CYCLES_PER_BIT - 1) begin
                        cycle_counter <= 0;
                        
                        if (bit_index == 0) begin
                            state <= RESET;
                        end else begin
                            bit_index <= bit_index - 1;
                        end
                    end else begin
                        cycle_counter <= cycle_counter + 1;
                    end
                end
                
                RESET: begin
                    led_out <= 1'b0;
                    if (cycle_counter >= (CLOCK_FREQ / 10000)) begin
                        cycle_counter <= 0;
                        state <= IDLE;
                        busy <= 1'b0;
                    end else begin
                        cycle_counter <= cycle_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule
