module task4(input logic CLOCK_50, input logic [3:0] KEY,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5);

    logic rst_n;
    assign rst_n = KEY[3];

    // Signal to start the cracking process once after reset
    logic start_crack;
    logic crack_en;

    // FSM to generate a single 'en' pulse after reset
    typedef enum logic [1:0] {IDLE, START, RUNNING} start_state_t;
    start_state_t start_state;

    always_ff @(posedge CLOCK_50) begin
        if (!rst_n)
            start_state <= IDLE;
        else
            case(start_state)
                IDLE: start_state <= START;
                START: start_state <= RUNNING;
                RUNNING: ; // Stay in running
            endcase
    end

    assign crack_en = (start_state == START);

    // Crack module signals
    logic crack_rdy;
    logic [23:0] cracked_key;
    logic key_is_valid;
    logic [7:0] ct_addr;
    logic [7:0] ct_rddata;

    // Instantiate the ciphertext memory.
    // This memory should be pre-initialized with the ciphertext to be cracked.
    // For the FPGA, this is done via a .mif file in the Quartus project settings.
    ct_mem ct(
        .address(ct_addr),
        .clock(CLOCK_50),
        .q(ct_rddata)
    );

    // Instantiate the crack module
    crack c(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .en(crack_en),
        .rdy(crack_rdy),
        .key(cracked_key),
        .key_valid(key_is_valid),
        .ct_addr(ct_addr),
        .ct_rddata(ct_rddata)
    );

    // 7-segment display logic
    logic [6:0] hex_displays [5:0];
    
    // Convert 4-bit nibble to 7-segment pattern
    function automatic [6:0] hex_to_7seg(input logic [3:0] nibble);
        case (nibble)
            4'h0: return 7'b1000000; // 0
            4'h1: return 7'b1111001; // 1
            4'h2: return 7'b0100100; // 2
            4'h3: return 7'b0110000; // 3
            4'h4: return 7'b0011001; // 4
            4'h5: return 7'b0010010; // 5
            4'h6: return 7'b0000010; // 6
            4'h7: return 7'b1111000; // 7
            4'h8: return 7'b0000000; // 8
            4'h9: return 7'b0010000; // 9
            4'hA: return 7'b0001000; // A
            4'hB: return 7'b0000011; // b
            4'hC: return 7'b1000110; // C
            4'hD: return 7'b0100001; // d
            4'hE: return 7'b0000110; // E
            4'hF: return 7'b0001110; // F
            default: return 7'b1111111; // Off
        endcase
    endfunction

    // Logic to control display output based on crack module state
    always_comb begin
        if (!crack_rdy) begin
            // Blank displays while computing
            for (int i = 0; i < 6; i++)
                hex_displays[i] = 7'b1111111; // All segments off
        end else begin
            if (key_is_valid) begin
                // Display the cracked key
                hex_displays[5] = hex_to_7seg(cracked_key[23:20]);
                hex_displays[4] = hex_to_7seg(cracked_key[19:16]);
                hex_displays[3] = hex_to_7seg(cracked_key[15:12]);
                hex_displays[2] = hex_to_7seg(cracked_key[11:8]);
                hex_displays[1] = hex_to_7seg(cracked_key[7:4]);
                hex_displays[0] = hex_to_7seg(cracked_key[3:0]);
            end else begin
                // Display "------" if no key was found
                for (int i = 0; i < 6; i++)
                    hex_displays[i] = 7'b0111111; // Dash
            end
        end
    end

    assign HEX5 = hex_displays[5];
    assign HEX4 = hex_displays[4];
    assign HEX3 = hex_displays[3];
    assign HEX2 = hex_displays[2];
    assign HEX1 = hex_displays[1];
    assign HEX0 = hex_displays[0];

endmodule: task4
