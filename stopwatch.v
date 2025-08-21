module stopwatch(
    input clk,
    input hard_reset,
    input start,
    input soft_reset,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    wire [1:0] en;
    reg [3:0] ms1, ms0, s1, s0, m1, m0;
    reg [19:0] cnt; // ~50 MHz / 100 = 500000
    reg [25:0] clk_div;

    // FSM Instance
    stopwatch_fsm fsm_inst (
        .clk(clk),
        .hard_reset(hard_reset),
        .start(start),
        .soft_reset(soft_reset),
        .en(en)
    );

    // Timing Counter
    always @(posedge clk or negedge hard_reset) begin
        if (!hard_reset) begin
            {ms1, ms0, s1, s0, m1, m0} <= 0;
            cnt <= 0;
        end else if (en == 2'b01) begin  // COUNTING state
            if (cnt == 500000) begin  // 1ms tick
                cnt <= 0;

                if (ms0 == 9) begin
                    ms0 <= 0;
                    if (ms1 == 9) begin
                        ms1 <= 0;
                        if (s0 == 9) begin
                            s0 <= 0;
                            if (s1 == 5) begin
                                s1 <= 0;
                                if (m0 == 9) begin
                                    m0 <= 0;
                                    if (m1 == 5) m1 <= 0;
                                    else m1 <= m1 + 1;
                                end else m0 <= m0 + 1;
                            end else s1 <= s1 + 1;
                        end else s0 <= s0 + 1;
                    end else ms1 <= ms1 + 1;
                end else ms0 <= ms0 + 1;

            end else cnt <= cnt + 1;
        end else if (en == 2'b00) begin // RESET
            {ms1, ms0, s1, s0, m1, m0} <= 0;
            cnt <= 0;
        end
    end

    // 7-Segment Display Instances (dot not used here)
    dec_7seg d0 (.a(ms0), .seg(HEX0), .dot(1'b1)); // 1/100s
    dec_7seg d1 (.a(ms1), .seg(HEX1), .dot(1'b0));
    dec_7seg d2 (.a(s0),  .seg(HEX2), .dot(1'b1)); // seconds
    dec_7seg d3 (.a(s1),  .seg(HEX3), .dot(1'b0));
    dec_7seg d4 (.a(m0),  .seg(HEX4), .dot(1'b1)); // minutes
    dec_7seg d5 (.a(m1),  .seg(HEX5), .dot(1'b0));

endmodule

Stopwatch FSM:

module stopwatch_fsm(
    input clk,
    input hard_reset,
    input start,
    input soft_reset,
    output reg [1:0] en // Enable signal
);

    // Define states
    reg [1:0] state, next_state;
    localparam RESET = 2'b00, RUN = 2'b01, PAUSE = 2'b10;

    // State transition logic
    always @(posedge clk or negedge hard_reset) begin
        if (!hard_reset)
            state <= RESET;
        else
            state <= next_state;
    end

    // Next state logic
    always @(state or start or soft_reset) begin
        case(state)
            RESET: next_state = (start) ? RUN : RESET;
            RUN:   next_state = (soft_reset) ? RESET : PAUSE; // Add additional conditions as needed
            PAUSE: next_state = (start) ? RUN : PAUSE;
            default: next_state = RESET;
        endcase
    end

    // Output enable signal based on the current state
    always @(state) begin
        case(state)
            RESET: en = 2'b00; // Disable counting
            RUN:   en = 2'b01; // Enable counting
            PAUSE: en = 2'b10; // Pause counting
            default: en = 2'b00;
        endcase
    end

endmodule

7 Segment Display:

module dec_7seg(
    input [3:0] a,       // 4-bit binary input
    output reg [7:0] seg, // 7-segment output (active low)
    input dot            // Dot control (optional, can be 1 or 0)
);

    always @(a) begin
        case(a)
            4'b0000: seg = 8'b11000000; // 0
            4'b0001: seg = 8'b11111001; // 1
            4'b0010: seg = 8'b10100100; // 2
            4'b0011: seg = 8'b10110000; // 3
            4'b0100: seg = 8'b10011001; // 4
            4'b0101: seg = 8'b10010010; // 5
            4'b0110: seg = 8'b10000010; // 6
            4'b0111: seg = 8'b11111000; // 7
            4'b1000: seg = 8'b10000000; // 8
            4'b1001: seg = 8'b10010000; // 9
            default: seg = 8'b11111111; // Default (all segments off)
        endcase
       
        // Handle dot control
        if (dot)
            seg[7] = 1'b1; // Turn on dot if required
        else
            seg[7] = 1'b0; // Turn off dot
    end

endmodule
