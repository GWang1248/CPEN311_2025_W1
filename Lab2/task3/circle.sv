module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

     parameter BLACK = 3'b000;
     parameter BLUE = 3'b001;
     parameter GREEN = 3'b010;
     parameter YELLOW = 3'b110;
     parameter RED = 3'b100;
     parameter WHITE = 3'b111;

     logic [7:0] offset_x, offset_y;
     logic [2:0] plot_counter;
     logic signed [9:0] crit;
     enum logic [2:0] {IDLE, CALC, DRAW, DONE} state, next_state;

     always_ff @(posedge clk) begin //Statemachine Transition
          if (!rst_n) begin
               state <= IDLE;
          end
          else begin
               vga_colour <= GREEN;
               state <= next_state;
               case (state)
               IDLE: begin
                    if (start) begin
                         offset_y <= 0;
                         offset_x <= radius;
                         crit <= 1 - radius;
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
               DRAW: vga_plot <= 1'b1;
               DONE: done <= 1'b1;
               default: vga_plot <= 1'b0;
          endcase
          end
     end

     always_ff @(posedge clk or negedge rst_n) begin //Plot Counter
          if (!rst_n)
               plot_counter <= 3'd0;
          else begin
               case (state)
                    DRAW: plot_counter <= plot_counter + 3'd1;
                    default: plot_counter <= 3'd0;
               endcase
          end
     end

     always_comb begin //Process State Transition Logic
          case (state)
               IDLE: begin
                    if (start)
                         next_state = CALC;
                    else
                         next_state = IDLE;
               end
               CALC: begin
                    if (offset_y + 1 > offset_x || radius == 8'd0)
                         next_state = DONE;
                    else
                         next_state = DRAW;
               end
               DRAW: begin
                    if (plot_counter == 3'd7)
                         next_state = CALC;
                    else
                         next_state = DRAW;
               end
               DONE: next_state = IDLE;
               default: next_state = IDLE;
          endcase
     end

     always_comb begin //Octant Pixel Drawing Logic
          if (state == DRAW) begin
               case (plot_counter)
                    3'd0: begin
                         vga_x = centre_x + offset_x;
                         vga_y = centre_y + offset_y;
                    end
                    3'd1: begin
                         vga_x = centre_x + offset_y;
                         vga_y = centre_y + offset_x;
                    end
                    3'd2: begin
                         vga_x = centre_x - offset_x;
                         vga_y = centre_y + offset_y;
                    end
                    3'd3: begin
                         vga_x = centre_x - offset_y;
                         vga_y = centre_y + offset_x;
                    end
                    3'd4: begin
                         vga_x = centre_x - offset_x;
                         vga_y = centre_y - offset_y;
                    end
                    3'd5: begin
                         vga_x = centre_x - offset_y;
                         vga_y = centre_y - offset_x;
                    end
                    3'd6: begin
                         vga_x = centre_x + offset_x;
                         vga_y = centre_y - offset_y;
                    end
                    3'd7: begin
                         vga_x = centre_x + offset_y;
                         vga_y = centre_y - offset_x;
                    end
                    default: begin
                         vga_x = 8'd0;
                         vga_y = 7'd0;
                    end
               endcase
          end
          else begin
               vga_x = 8'd0;
               vga_y = 7'd0;
          end
     end
endmodule