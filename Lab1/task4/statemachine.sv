module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

//Define States
    logic [3:0] state;

    parameter IDLE = 2'd0;
    parameter P1 = 2'd1;
    parameter D1 = 2'd2;
    parameter P2 = 2'd3;
    parameter D2 = 2'd4;
    parameter DIVERGE = 2'd5;
    parameter P3 = 2'd6;
    parameter D3 = 2'd7;
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
                IDLE: state <= P1;
                P1: begin
                    state <= D1;
                    load_pcard1 <= 1;
                end
                D1: begin
                    state <= P2;
                    load_dcard1 <= 1;
                end
                P2: begin
                    state <= D2;
                    load_pcard2 <= 1;
                end
                D2: begin
                    state <= DIVERGE;
                    load_dcard2 <= 1;
                end
                DIVERGE: begin
                    if (pscore >= 8 || dscore >= 8) //Natural
                        state <= OVER;
                    else //Player scores 0 to 7
                        state <= P3;
                end
                P3: begin //Player gets 3rd card condition
                    if (pscore >= 0 && pscore <= 5) begin
                        load_pcard3 <= 1;
                        state <= D3_1
                    end
                    else begin
                        load_pcard3 <= 0;
                        state <= D3_2;
                    end
                end
                D3_1: begin // Dealer gets 3rd card condition if player gets 3rd card
                    case (dscore)
                        7: load_dcard3 <= 0;
                        6: begin
                            if (pcard3 == 6 || pcard3 == 7)
                                load_dcard3 <= 1;
                        end
                        5: begin
                            if (pcard3 >= 4 && pcard3 <=7)
                                load_dcard3 <= 1;
                        end
                        4: begin
                            if (pcard3 >= 2 && pcard3 <=7)
                                load_dcard3 <= 1;
                        end
                        3: begin
                            if (pcard3 != 8)
                                load_dcard3 <= 1;
                        end
                        default: load_dcard3 <= 1;
                    endcase
                    state <= OVER;
                end
                D3_2: begin //Dealer gets 3rd card condition if player doesnt get 3rd card
                    if (dscore >=0 && dscore <= 5)
                        load_dcard3 <= 1;
                    state <= OVER;
                end
                OVER: begin //Score calculation
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
                default: begin
                    load_dcard1 <= 0;
                    load_pcard1 <= 0;
                    load_dcard2 <= 0;
                    load_pcard2 <= 0;
                    load_dcard3 <= 0;
                    load_pcard3 <= 0;
                end
            endcase
        end
    end

endmodule