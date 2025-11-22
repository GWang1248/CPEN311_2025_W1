module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    typedef enum logic [3:0] {ARC4_RDY, ARC4_EN, ARC4, CHECK_REQ, CHECK_GET, CHECK_COMP, CHECK_RSLT, LOOP, DONE} state_t;
	state_t state, next_state;
    // your code here
    logic [7:0] pt_addr;
    logic [7:0] pt_rddata;
    logic [7:0] pt_wrdata;
    logic rdy, en, pt_wren;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt( /* connect ports */ 
        .address(pt_addr),
        .clock(clk),
        .data(pt_wrdata), 
		.wren(pt_wren),
        .q(pt_rddata));

    arc4 a4( /* connect ports */ 
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .rdy(rdy),
        .key(key), 
		.ct_addr(ct_addr),
        .ct_rddata(ct_rddata),
        .pt_addr(pt_addr), 
		.pt_rddata(pt_rddata),
        .pt_wrdata(pt_wrdata),
        .pt_wren(pt_wren));

    // your code here

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= INIT_RDY;
        else
            state <= next_state;
    end

    always_comb begin
    end

endmodule: crack
