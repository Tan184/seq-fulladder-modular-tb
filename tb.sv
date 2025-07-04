`timescale 1ns / 1ps


// Interface
interface fa_int(input logic clk);
  logic a, b, cin;
  logic sum, cout;
endinterface


// Transaction
class txn;
  rand logic a, b, cin;
  logic sum, cout;
endclass


// Generator
class generator;
  mailbox gen2drv;

  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task run();
    txn t;
    repeat (25) begin
      t = new();
      t.randomize();
      gen2drv.put(t);
      //$display("a: %0b, b: %0b, c: %0b", t.a, t.b, t.cin);
      //To check working of generator: It works.
    end
  endtask
endclass


// Driver
class driver;
  virtual fa_int tb_int;
  mailbox gen2drv;

  function new(virtual fa_int tb_int, mailbox gen2drv);
    this.tb_int = tb_int;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    txn t;
    forever begin
      gen2drv.get(t);
      @(posedge tb_int.clk); 
      tb_int.a = t.a;
      tb_int.b = t.b;
      tb_int.cin = t.cin;
      //$display("a: %0b, b: %0b, c: %0b", tb_int.a, tb_int.b, tb_int.cin);
      //To check working of driver: It works.
    end
  endtask
endclass


// Monitor
class monitor;
  mailbox mon2scr;
  virtual fa_int tb_int;

  function new(virtual fa_int tb_int, mailbox mon2scr);
    this.tb_int = tb_int;
    this.mon2scr = mon2scr;
  endfunction

  task run();
    txn t;
    forever begin
      @(posedge tb_int.clk);
      t = new();
      t.a = tb_int.a;
      t.b = tb_int.b;
      t.cin = tb_int.cin;
      t.sum = tb_int.sum;
      t.cout = tb_int.cout;
      mon2scr.put(t);
    end
  endtask
endclass


// Scoreboard
class scoreboard;
  mailbox mon2scr;

  logic prev_a,   prev_b,   prev_cin;
  logic prev2_a,  prev2_b,  prev2_cin;
  logic prev3_a,  prev3_b,  prev3_cin;
  logic prev4_a,  prev4_b,  prev4_cin;
  //logic prev5_a,  prev5_b,  prev5_cin;

  int cycle_count;

  function new(mailbox mon2scr);
    this.mon2scr    = mon2scr;
    cycle_count     = 0;
  endfunction

  task run();
    txn    t;
    logic  expected_sum;
    logic  expected_cout;

    forever begin
      mon2scr.get(t);
      cycle_count++;

      if (cycle_count > 4) begin
        logic sum1   = prev4_a ^ prev4_b;
        logic carry1 = prev4_a & prev4_b;
        logic sum2   = sum1 ^ prev4_cin;
        logic carry2 = sum1 & prev4_cin;
        expected_sum  = sum2;
        expected_cout = carry1 | carry2;

        if (t.sum !== expected_sum || t.cout !== expected_cout) begin
          $display($time, " ERROR: a=%0b, b=%0b, cin=%0b | Expected cout=%0b, sum=%0b | Got cout=%0b, sum=%0b", prev4_a, prev4_b, prev4_cin, expected_cout, expected_sum, t.cout, t.sum);
        end else begin
          $display($time, " OK   : a=%0b, b=%0b, cin=%0b => cout=%0b, sum=%0b", prev4_a, prev4_b, prev4_cin, t.cout, t.sum);
        end
      end
      
      //prev5_a = prev4_a; prev5_b = prev4_b; prev5_cin = prev4_cin;
      prev4_a = prev3_a; prev4_b = prev3_b; prev4_cin = prev3_cin;
      prev3_a = prev2_a; prev3_b = prev2_b; prev3_cin = prev2_cin;
      prev2_a = prev_a;  prev2_b = prev_b; prev2_cin = prev_cin;
      prev_a = t.a; prev_b = t.b; prev_cin  = t.cin;
      
    end
  endtask
endclass



// Environment
class environment;
  generator gen;
  monitor mon;
  driver drv;
  scoreboard scr;

  mailbox gen2drv;
  mailbox mon2scr;

  virtual fa_int tb_int;

  function new(virtual fa_int tb_int);
    this.tb_int = tb_int;
    gen2drv = new();
    mon2scr = new();

    gen = new(gen2drv);
    drv = new(tb_int, gen2drv);
    mon = new(tb_int, mon2scr);
    scr = new(mon2scr);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scr.run();
    join_none
  endtask
endclass


// Testbench
module tb;
  logic clk;
  fa_int intf(clk);

  environment env;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  full_adder uut(
    .clk(clk),
    .a(intf.a),
    .b(intf.b),
    .cin(intf.cin),
    .sum(intf.sum),
    .cout(intf.cout)
  );

  initial begin
    env = new(intf);
    env.run();
    #200; 
    $finish;
  end
  
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars();
  end
endmodule


