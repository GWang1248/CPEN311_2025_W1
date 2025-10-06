// To reduce risk for physical button to generate bouncing signals

module debouncer(input logic fast_clock,
               input logic slow_clock,
               input logic resetb,
               output logic clock_tick);

   logic key_1, key_2;

   always_ff @(posedge fast_clock) begin // Give a non CDC clock tick
      if (!resetb) begin
         key_1 <= 1;
         key_2 <= 1;
      end
      else if (clock_tick) begin
         key_1 <= 1;
         key_2 <= key_1;
      end
   end

	assign clock_tick = key_1 && !key_2;

endmodule
