module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    enum logic [3:0] {IDLE, INIT_RDY, INIT_EN, INIT_DOING, INIT_DONE, KSA_RDY, KSA_EN, KSA_DOING, KSA_DONE, DONE} state, next_state;

    logic init_en, init_rdy, init_wren;
    logic ksa_en, ksa_rdy, ksa_wren;

    logic [7:0] init_address, init_wrdata;
    logic [7:0] ksa_address, ksa_wrdata, ksa_rddata;

    logic s_wren;
	logic [7:0] s_addr, s_wrdata;
	logic [7:0] s_rddata;    // read data from S memory

    logic [23:0] key;
    assign key[9:0] = SW[9:0];
    assign key[23:10] = 14'b0;

    s_mem s( /* connect ports */
		.address(s_addr),
		.clock(CLOCK_50),
		.data(s_wrdata),
		.wren(s_wren),
		.q(s_rddata));

    init init(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(init_en),
        .rdy(init_rdy), 
		.addr(init_address),
        .wrdata(init_wrdata),
        .wren(init_wren));

	ksa ksa(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(ksa_en),
        .rdy(ksa_rdy), 
		.key(key),
        .addr(ksa_address),
        .rddata(ksa_rddata),
        .wrdata(ksa_wrdata),
		.wren(ksa_wren));

    // your code here
    always_ff @(posedge CLOCK_50) begin
        if(!KEY[3])
            state <= IDLE;
        else 
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        init_en = 0;
        ksa_en = 0;
        s_wren = 0;
        s_addr = 0;
        s_wrdata = 0;
        ksa_rddata = s_rddata;
        case (state)
            IDLE: begin
                next_state = INIT_RDY;
            end
            INIT_RDY: begin
                if (init_rdy) begin
                    init_en = 1;
                    next_state = INIT_EN;
                end
            end
            INIT_EN: begin
                init_en = 0;
                next_state = INIT_DOING;
            end
            INIT_DOING: begin
                s_wren = init_wren;
                s_addr = init_address;
                s_wrdata = init_wrdata;
                if (init_rdy)
                    next_state = INIT_DONE;
            end
            INIT_DONE: next_state = KSA_RDY;
            KSA_RDY: begin
                if (ksa_rdy) begin
                    ksa_en = 1;
                    next_state = KSA_EN;
                end
            end
            KSA_EN: begin
                ksa_en = 0;
                next_state = KSA_DOING;
            end
            KSA_DOING: begin
                s_wren = ksa_wren;
                s_addr = ksa_address;
                s_wrdata = ksa_wrdata;
                if (ksa_rdy)
                    next_state = KSA_DONE;
            end
            KSA_DONE: next_state = DONE;
            DONE: ;
            default: ;
        endcase
    end

endmodule: task2
