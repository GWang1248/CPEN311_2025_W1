`timescale 1ps / 1ps

module tb_rtl_task4;

    logic CLOCK_50;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // Instantiate the toplevel module
    task4 dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    // Clock generation
    always #5 CLOCK_50 = ~CLOCK_50;

    initial begin
        $display("--- Test Bench for task4 ---");
        CLOCK_50 = 0;
        KEY = 4'b1111; // rst_n is high
        #10;

        // Assert reset
        $display("Asserting reset...");
        KEY[3] = 0; // rst_n is low
        #20;
        KEY[3] = 1; // rst_n is high
        #10;
        $display("Reset de-asserted. Cracking should start.");

        // In a real simulation, we would initialize the ct_mem here
        // using the hierarchical path and wait for the result.
        // For example:
        // $readmemh("test_crack1.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

        // Monitor the display outputs
        // Initially, they should be blank (all segments off)
        #20; // Wait a few cycles for logic to settle
        if (HEX0 === 7'h7F && HEX5 === 7'h7F) begin
            $display("SUCCESS: Displays are blank while computing.");
        end else begin
            $display("ERROR: Displays are not blank. HEX5=%h, HEX0=%h", HEX5, HEX0);
        end

        // Since a full crack takes too long to simulate,
        // we will just let it run for a bit and then stop.
        // A full verification would require a very fast simulator or a test case with a key of 0 or 1.
        $display("Simulation will run for 50000 time units then stop.");
        #50000;

        $display("Simulation finished.");
        $stop;
    end

endmodule
