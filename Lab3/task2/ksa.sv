module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here
    enum logic [5:0] {IDLE, REQ_S_I, GET_S_I, REQ_S_J, GET_S_J, WRITE_S_I, WRITE_S_J, DONE} state;

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
                REQ_S_I: state <= GET_S_I
            endcase
        end
    end


endmodule: ksa
