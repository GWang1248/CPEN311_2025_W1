module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

    parameter CONST = 11'd1732;
    logic [7:0] centre_x1, centre_x2, centre_x3;
    logic [6:0] centre_y1, centre_y2, centre_y3;

    assign centre_x1 = centre_x + diameter / 2;
    assign centre_x2 = centre_x - diameter / 2;
    assign centre_x3 = centre_x;

    assign centre_y1 = centre_y + diameter * CONST / 6000;
    assign centre_y2 = centre_y + diameter * CONST / 6000;
    assign centre_y3 = centre_y - diameter * CONST / 3000;

    circle cr1(.clk(clk), .rst_n(rst_n), .colour(colour), .centre_x(centre_x1), .centre_y(centre_y1),
                .radius(diameter), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));
    //circle cr2(.clk(clk), .rst_n(rst_n), .colour(colour), .centre_x(centre_x2), .centre_y(centre_y2),
                //.radius(diameter), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));
    //circle cr3(.clk(clk), .rst_n(rst_n), .colour(colour), .centre_x(centre_x3), .centre_y(centre_y3),
                //.radius(diameter), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));

endmodule
