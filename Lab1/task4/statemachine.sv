module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

//Define States
    logic [3:0] state;

    parameter IDLE = 4'b0000;
    parameter D1 = 4'b0001;
    parameter P1 = 4'b0010;
    parameter D2 = 4'b0011;
    parameter P2 = 4'b0100;
    parameter DIVERGE = 4'b0101;
    parameter OVER = 4'b1111;

//Statemachine Logic
    always_ff @(posedge slow_clock) begin

        if (resetb == 0) begin //Reset
            load_dcard1 <= 0;
            load_pcard1 <= 0;
            load_dcard2 <= 0;
            load_pcard2 <= 0;
            load_dcard3 <= 0;
            load_pcard3 <= 0;
            state <= IDLE;
        end

        else begin //Begin Baccarat
            load_dcard1 <= 0;
            load_pcard1 <= 0;
            load_dcard2 <= 0;
            load_pcard2 <= 0;
            load_dcard3 <= 0;
            load_pcard3 <= 0;
            case(state)
                IDLE: state <= D1;
                D1: begin
                    state <= P1;
                    load_dcard1 <= 1;
                end
                P1: begin
                    state <= D2;
                    load_pcard1 <= 1;
                end
                D2: begin
                    state <= P2;
                    load_dcard2 <= 1;
                end
                P2: begin
                    state <= DIVERGE;
                    load_pcard2 <= 1;
                end
                DIVERGE: begin
                    if (pscore >=8 || dscore >= 8)
                        state <= OVER;

                end
                OVER: begin
                    if (pscore > dscore)
                        player_win_light <= 1;
                    else if (dscore > pscore)
                        dealer_win_light <= 1;
                    else if (pscore == dscore) begin
                        dealer_win_light <= 1;
                        player_win_light <= 1;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule