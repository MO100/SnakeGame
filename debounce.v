module debounce (
    input        clk,       // Clock signal
    input        button_in, // Raw button input
    output reg   button_out // Debounced button output
);

    // Parameters for debounce timing
    parameter DEBOUNCE_TIME = 20_000; // 20 ms for 50 MHz clock

    reg [19:0] counter = 0; // Counter for debounce timing
    reg button_state = 0;   // Current stable button state
    reg button_prev = 0;    // Previous raw button state

    always @(posedge clk) begin
        if (button_in != button_prev) begin
            // Button state changed, reset the counter
            counter <= 0;
        end else if (counter < DEBOUNCE_TIME) begin
            // Increment counter if it hasn't reached debounce time
            counter <= counter + 1;
        end else if (counter == DEBOUNCE_TIME) begin
            // Update stable button state after debounce time
            button_state <= button_in;
        end

        // Save current raw button state for comparison
        button_prev <= button_in;
    end

    // Update debounced output in a separate always block
    always @(posedge clk) begin
        button_out <= button_state;
    end

endmodule
