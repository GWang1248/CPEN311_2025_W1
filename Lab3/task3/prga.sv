module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
    typedef enum logic [4:0] {IDLE, READ_CT, WRITE_MSG, LOOP, REQ_S_I, GET_S_I, UPD_J, REQ_S_J, GET_S_J, WRITE_J, WRITE_I, REQ_PAD, GET_PAD, WRITE_PT, DONE} state_t;
	state_t state, next_state;

    logic [7:0] i, j, k, s_i, s_j;
    logic [7:0] i_next, j_next, k_next, s_i_next, s_j_next;
    logic [7:0] msg;
    logic [7:0] msg_next;

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
            i <= 8'd0;
            j <= 8'd0;
            k <= 8'd0;
            s_i <= 8'd0;
            s_j <= 8'd0;
            msg <= 8'd0;
        else
            state <= next_state;
            i <= next_i;
            j <= next_j;
            k <= next_k;
            s_i <= s_i_next;
            s_j <= s_i_next;
            msg <= msg_next;
    end

    always_comb begin
        next_state = state;
		i_next = i;
		j_next = j;
        k_next = k;
		s_i_next = s_i;
		s_j_next = s_j;
        msg_next = msg;
		rdy = 0;
        case (state)
            IDLE: begin
                rdy = 1;
                if(en == 1) begin
					i_next = 0;
					j_next = 0;
                    k_next = 1;
					s_i_next = 0;
					s_j_next = 0;
					rdy = 0;
					next_state = READ_CT;	
				end
				else begin
					next_state = IDLE;
					rdy = 1;
				end
            end
            READ_CT: next_state = WRITE_MSG;
            WRITE_MSG: next_state = LOOP
            LOOP: begin
                if (k > msg)
                    next_state = DONE;
                else begin
                    i_next = (i + 1) % 256;
					next_state = REQ_S_I;
                end
            end
            REQ_S_I: next_state = GET_S_I;
            GET_S_I: next_state = UPD_J;
            UPD_J: begin
                s_i_next = s_rddata;
                j_next = (s_i + j) % 256;
                next_state = REQ_S_J;
            end
            REQ_S_J: next_state = GET_S_J;
            GET_S_J: next_state = WRITE_J;
            WRITE_J: next_state = WRITE_I;
            WRITE_I: next_state = GET_PAD;
            REQ_PAD: next_state = GET_PAD;
            GET_PAD: next_state = GET_PAD;
            WRITE_PT: begin
                k_next = k + 8'd1;
                next_state = LOOP;
            end
            DONE: next_state = DONE;
        endcase
    end

    
endmodule: prga
