`timescale 1ns/1ps

//Randomizaition check macro
`define SV_RAND_CHECK(r) \
	do begin \
		if (!(r)) begin \
			$display("%s: %0d: Randomization failed \"%s\"", \
			`__FILE__, `__LINE__, `"r`");\
			$finish;\
		end \
	end while (0)

//Defining a clocking block
interface MyBus (input logic slow_clock);
    logic resetb;
    logic [3:0] dscore, pscore, pcard3;
    logic load_pcard1, load_pcard2, load_pcard3;
    logic load_dcard1, load_dcard2, load_dcard3;
    logic player_win_light, dealer_win_light;

    //For this clocking block, we are driving dscore, pscore, pcard3 and resetb
    //We take the value of other inputs
    clocking cb @(posedge slow_clock);

        //input in clocking block means output produced from the DUT
        input load_pcard1, load_pcard2, load_pcard3;
        input load_dcard1, load_dcard2, load_dcard3;
        input player_win_light, dealer_win_light;

        //output in clocking block means input given to the DUT
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

    function display(string tag = "tr");
        $display("[%0t] %s pscore = %0d dscore = %0d pcard3 = %0d", $time, tag, pscore, dscore, pcard3);
    endfunction
endclass

//Generate how many tests should be covered (default 10)
//During each round generate different handle tr and put into mailbox
//Which will be further delivered to Driver
class Generator;
    mailbox #(RoundTrans) mbox;

    function new (mailbox #(RoundTrans) mbox);
        this.mbox = mbox;
    endfunction

    task run(int rounds = 10);
        RoundTrans tr;
        repeat (rounds) begin
            tr = new();
            SV_RAND_CHECK(tr.randomize());
            tr.display();
            mbox.put(tr);
        end
    endtask
endclass

//Driver get data generated from Generator (type RoundTrans)
//Put data into clocking block to drive them through DUT
class Driver;
    virtual MyBus bus;
    mailbox #(RoundTrans) mbox;

    function new (virtual MyBus bus, mailbox #(RoundTrans) mbox);
        this.bus = bus;
        this.mbox = mbox;
    endfunction

    task run_a_round(RoundTrans tr);
        bus.cb.pscore <= tr.pscore;
        bus.cb.dscore <= tr.dscore;
        bus.cb.pcard3 <= tr.pcard3;

        bus.cb.resetb <= 0;
        repeat (2) @(bus.cb);
        bus.cb.resetb <= 1;

        repeat (9) @(bus.cb);
    endtask

    task run();
        RoundTrans tr;
        forever begin
            mbox.get(tr);
            tr.display();
            run_a_round(tr);
        end
    endtask
endclass

//Monitor structure to take DUT output and ready to put into mailbox
//Complete output signal of the DUT
typedef struct packed {
    int state;
    bit load_p1, load_p2, load_p3;
    bit load_d1, load_d2, load_d3;
    bit player_win_light, dealer_win_light;
} out_sample_t;

//Observe output signal from DUT
class Monitor;
    virtual MyBus bus;
    mailbox #(out_sample_t) mbox;

    int state_in_round;
    bit in_round;

    function new (virtual MyBus bus, mailbox #(out_sample_t) mbox);
        this.bus = bus;
        this.mbox = mbox;
        this.state_in_round = 0;
        this.in_round = 0;
    endfunction

    task run();
        forever begin
            //Observe the resetb from DUT to determine the testing round start
            @(bus.cb);
            if (bus.cb.resetb == 1 && !in_round) begin
                in_round = 1;
                state_in_round = 0;
            end

            //Store DUT output to out_sample_t type, put into mailbox
            if (in_round) begin
                out_sample_t s;
                state_in_round++;
                s.state = state_in_round;
                s.load_p1 = bus.cb.load_pcard1;
                s.load_p2 = bus.cb.load_pcard2;
                s.load_p3 = bus.cb.load_pcard3;
                s.load_d1 = bus.cb.load_dcard1;
                s.load_d2 = bus.cb.load_dcard2;
                s.load_d3 = bus.cb.load_dcard3;
                s.player_win_light = bus.cb.player_win_light;
                s.dealer_win_light = bus.cb.dealer_win_light;
                mbox.put(s);

                if (state_in_round >= 9) begin
                    in_round = 0;
                end
            end
        end
    endtask
endclass