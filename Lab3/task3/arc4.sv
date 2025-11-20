module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here

    s_mem s ( /* connect ports */ 
		.address (s_addr),
        .clock   (CLOCK_50),
        .data    (s_data_in),
        .wren    (s_wren),
        .q       (s_data_out));

    init i( /* connect ports */ 
        .clk    (CLOCK_50),
        .rst_n  (rst_n),
        .en     (init_en),
        .rdy    (init_rdy),
        .addr   (init_addr),
        .wrdata (init_wrdata),
        .wren   (init_wren));

    ksa k ( /* connect ports */ 
        .clk    (CLOCK_50),
        .rst_n  (rst_n),
        .en     (ksa_en),
        .rdy    (ksa_rdy),
        .key    (ksa_key),
        .addr   (ksa_addr),
        .rddata (s_data_out),
        .wrdata (ksa_wrdata),
        .wren   (ksa_wren));
        
    prga p( /* connect ports */ );

    // your code here

endmodule: arc4
