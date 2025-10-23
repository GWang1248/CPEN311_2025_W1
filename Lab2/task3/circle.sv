module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

     parameter GREEN = 3'b010;

     assign vga_colour = GREEN;

     logic [9:0] offset_x, offset_y;
     logic [2:0] plot_counter;
     logic signed [11:0] crit;
     enum logic [5:0] {IDLE, CALC, O1, O2, O3, O4, O5, O6, O7, O8, DONE} state, next_state;

     always_ff @(posedge clk) begin //Statemachine Transition
          if (!rst_n) begin
               state <= IDLE;
               offset_y <= 0;
               offset_x <= 0;
               crit <= 0;
               done <= 0;
          end
          else begin
               state <= next_state;
               done <= 1'b0;
               case (state)
                    IDLE: begin
                         if (start) begin
                              offset_y <= 0;
                              offset_x <= $signed({2'b00,radius});
                              crit <= 1 - $signed({4'b0000,radius});
                         end
                    end
                    CALC: begin
                         offset_y <= offset_y + 1;
                         if (crit <= 0)
                              crit <= crit + 2 * offset_y + 1;
                         else begin
                              offset_x <= offset_x + 1;
                              crit <= crit + 2 * (offset_y - offset_x) + 1;
                         end
                    end
                    DONE: done <= 1'b1;
                    default: done <= 1'b0;
               endcase
          end
     end

     always_comb begin //Process State Transition Logic
		vga_x = 8'b0;
		vga_y = 7'b0;
          case (state)
               IDLE: begin
                    if (start)
                         next_state = O1;
                    else
                         next_state = IDLE;
                    vga_plot = 1'b0;
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
                    next_state = O3;
               end
               O3: begin
                    vga_x = centre_x - offset_x;
                    vga_y = centre_y + offset_y;
                    vga_plot = 1'b1;
                    next_state = O4;
               end
               O4: begin
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
                    next_state = O7;
               end
               O7: begin
                    vga_x = centre_x + offset_y;
                    vga_y = centre_y - offset_x;
                    vga_plot = 1'b1;
                    next_state = O8;
               end
               O8: begin
                    vga_x = centre_x + offset_x;
                    vga_y = centre_y - offset_y;
                    vga_plot = 1'b1;
                    next_state = CALC;
               end
               CALC: begin
                    if (offset_y > offset_x)
                         next_state = DONE;
                    else
                         next_state = O1;
                    vga_plot = 1'b0;
               end
               DONE: begin
                    next_state = DONE;
                    vga_plot = 1'b0;
               end
               default: begin 
                    next_state = IDLE;
                    vga_plot = 1'b0;
               end
          endcase
     end
endmodule