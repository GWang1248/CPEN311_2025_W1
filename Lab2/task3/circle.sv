module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

     parameter GREEN = 3'b010;

     assign vga_colour = GREEN;

     logic signed [8:0] offset_x, offset_y;
     logic [2:0] plot_counter;
     logic signed [9:0] crit;
     enum logic [5:0] {IDLE, CALC, O1, O2, O3, O4, O5, O6, O7, O8, DONE} state, next_state;

     always_comb begin
          vga_plot = 0;
		vga_x = 0;
		vga_y = 0;
          next_state = state;
          case (state)
               IDLE:  begin
                    if (start)
                         next_state = O1;
                    else
                         next_state = IDLE;
               end
               O1: begin
                    vga_x = centre_x + offset_x;
                    vga_y = centre_y + offset_y;
                    vga_plot = 1'b1;
                    next_state = O2;
               end
               O2: begin
                    vga_x = centre_x + offset_y;
                    vga_y = centre_y + offset_x;
                    vga_plot = 1'b1;
                    next_state = O4;
               end
               O4: begin
                    vga_x = centre_x - offset_x;
                    vga_y = centre_y + offset_y;
                    vga_plot = 1'b1;
                    next_state = O3;
               end
               O3: begin
                    vga_x = centre_x - offset_y;
                    vga_y = centre_y + offset_x;
                    vga_plot = 1'b1;
                    next_state = O5;
               end
               O5: begin
                    vga_x = centre_x - offset_x;
                    vga_y = centre_y - offset_y;
                    vga_plot = 1'b1;
                    next_state = O6;
               end
               O6: begin
                    vga_x = centre_x - offset_y;
                    vga_y = centre_y - offset_x;
                    vga_plot = 1'b1;
                    next_state = O8;
               end
               O8: begin
                    vga_x = centre_x + offset_x;
                    vga_y = centre_y - offset_y;
                    vga_plot = 1'b1;
                    next_state = O7;
               end
               O7: begin
                    vga_x = centre_x + offset_y;
                    vga_y = centre_y - offset_x;
                    vga_plot = 1'b1;
                    next_state = CALC;
               end
               CALC: begin
                    if (offset_y > offset_x)
                         next_state = DONE;
                    else
                         next_state = O1;
               end
               DONE: next_state = DONE;
               default: next_state = IDLE;
          endcase
     end

     always_ff @(posedge clk) begin
          if (!rst_n) begin //Reset Logic
               state <= IDLE;
               offset_x <= 0;
               offset_y <= 0;
               crit <= 0;
               done <= 0;
          end
          else begin //Sync all the calculations within clk cycles
               state <= next_state;
               if (state == IDLE && start) begin //Logic before while block
                    offset_y <= 0;
                    offset_x <= radius;
                    crit <= 10'sd1 - $signed(radius);
               end
               if (state == CALC) begin //Logic after drawing at octants, recalculation
                    offset_y <= offset_y + 1;
                    if (crit <= 0)
                         crit <= crit + ((offset_y <<< 1)+1); // <<<: leftshift with sign preserved
                    else begin
                         offset_x <= offset_x - 1;
                         crit <= crit + (((offset_y - offset_x) <<< 1) + 1);
                    end
               end
               if (state == DONE) begin
                    done <= 1;
                    if (!start)
                         done <= 1'b0;
               end
          end
     end

endmodule