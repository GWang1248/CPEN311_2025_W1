module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
    enum logic [5:0] {IDLE, REQ_S_I, GET_S_I, UPD_J, REQ_S_J, GET_S_J, WRITE_S_I, WRITE_S_J, UPD_I, DONE} state;

    logic [7:0] i, s_i;
    logic [7:0] j, s_j;

    always_ff @(posedge clk) begin
        if (!rst_n) begin //Reset Condition
            state <= IDLE;
            i <= 0;
            j <= 0;
            s_i <= 0;
            s_j <= 0;
        end
        else begin //Timing-related Statemachines
            case (state)
                IDLE: begin
                    i <= 0;
                    j <= 0;
                    s_i <= 0;
                    s_j <= 0;
                    if (en)
                        state <= REQ_S_I;
                    else
                        state <= IDLE;
                end
                REQ_S_I: state <= GET_S_I;
                GET_S_I: begin //Read s[i] from mem
                    s_i <= rddata;
                    state <= UPD_J;
                end
                UPD_J: begin //Calculate j and write it back to mem
                    if (i % 3 == 2) begin
						j <= (j + s_i + key[7:0]) % 256;	
					end
					else if (i % 3 == 1) begin
						j <= (j + s_i + key[15:8]) % 256;
					end
					else begin
						j <= (j + s_i + key[23:16]) % 256;
					end
                    state <= REQ_S_J;
                end
                REQ_S_J: state <= GET_S_J;
                GET_S_J: begin //Get s[j] from mem
                    s_j <= rddata;
                    state <= WRITE_S_I;
                end
                WRITE_S_I: state <= WRITE_S_J;
                WRITE_S_J: state <= UPD_I;
                UPD_I: begin //Calculate i and write it back to mem, at the same time check loop condition
                    if (i < 255) begin
						i <= i + 8'd1;
						state <= REQ_S_I;
					end
					else begin
					    state <= DONE;
					end
                end
                DONE: state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end

    always_comb begin
        addr = 0;
        wrdata = 0;
        wren = 0;
        rdy = 0;
        case (state)
            IDLE: rdy = 1;
            REQ_S_I: addr = i;
            REQ_S_J: addr = j;
            WRITE_S_I: begin
                addr = j;
                wrdata = s_i;
                wren = 1;
            end
            WRITE_S_J: begin
                addr = i;
                wrdata = s_j;
                wren = 1;
            end
            DONE: rdy = 1;
            default:;
        endcase
    end

endmodule: ksa
