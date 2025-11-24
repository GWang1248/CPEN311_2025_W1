module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here
    
    typedef enum logic [4:0] {} state_t;
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt( /* connect ports */ );

    // for this task only, you may ADD ports to crack
    crack c1(
        .step(),
        .start_key(),
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(en),
        .rdy(rdy),
        .key(c_key),
        .key_valid(key_valid),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata)
    );
    crack c2(
        .step(),
        .start_key(),
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .en(en),
        .rdy(rdy),
        .key(c_key),
        .key_valid(key_valid),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata)
    );
    
    // your code here

endmodule: doublecrack
