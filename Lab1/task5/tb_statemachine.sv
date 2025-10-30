`timescale 1ns/1ps
//Defining a clocking block
interface MyBus (input logic slow_clock);
    logic resetb;
    logic [3:0] dscore, pscore, pcard3;
    logic load_pcard1, load_pcard2, load_pcard3;
    logic load_dcard1, load_dcard2, load_dcard3;
    logic player_win_light, dealer_win_light;

    //For this clocking block, we are driving dscore, pscore, pcard3 and resetb
    //We take the value of other inputs
    //input in clocking block means output produced from the DUT
    //output in clocking block means input given to the DUT
    clocking cb @(posedge slow_clock);
        input load_pcard1, load_pcard2, load_pcard3;
        input load_dcard1, load_dcard2, load_dcard3;
        input player_win_light, dealer_win_light;

        output resetb, dscore, pscore, pcard3;
    endclocking
endinterface

// Generates Transaction about last number of card for player/dealer
class RoundTrans;
    rand bit [3:0] pscore;
    rand bit [3:0] dscore;
    rand bit [3:0] pcard3;

    //Constraint about the score of player/dealer: 0~9
    constraint c_range{
        pscore inside {[0:9]};
        dscore inside {[0:9]};
        pcard3 inside {[0:9]};
    }

    function display();
        $display("[%0t] pscore = %0d dscore = %0d pcard3 = %0d", $time, pscore, dscore, pcard3);
    endfunction
endclass