module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

//Initialize
    assign load_dcard1 = 0;
    assign load_pcard1 = 0;
    assign load_dcard2 = 0;
    assign load_pcard2 = 0;
    assign load_dcard3 = 0;
    assign load_pcard3 = 0;

//Define States
    logic [3:0] state;
    logic [3:0] next_state;

    parameter IDLE = 4'b0000;
    parameter D1 = 4'b0001;
    parameter P1 = 4'b0010;
    parameter D2 = 4'b0011;
    parameter P2 = 4'b0100;
    parameter DIVERGE = 4'b0101;

    always_ff @(posedge slow_clock) begin //Beginning of State Machine
        if (resetb == 0)
            state = IDLE; //Reset State -> Idle
        else begin
            case (state)
                IDLE: begin
                    state = D1;
                end
                D1: begin
                    state = P1;
                    load_dcard1 = 1;
                end
                P1: begin
                    state = D2;
                    load_pcard1 = 1;
                end
                D2: begin
                    state = P2;
                    load_dcard2 = 1
                end
                P2: begin
                    state = DIVERGE;
                    load_pcard2 = 1
                end
                DIVERGE: begin
                    //NOT FINISHED YET
                end
            endcase
        end
    end

endmodule