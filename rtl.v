module half_adder(
  input clk,
  input a,
  input b,
  output reg sum,
  output reg carry
);

  always @(posedge clk) begin
    sum <= a ^ b;
    carry <= a & b;
  end
endmodule

module full_adder(
  input clk,
  input a,
  input b,
  input cin,
  output reg sum,
  output reg cout
);

  reg a_reg, b_reg, cin_reg;
  reg carry1_delayed;
  //reg a_reg2, b_reg2, cin_reg2;

  wire sum1, carry1, sum2, carry2;
  
  always @(posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    cin_reg <= cin;
    
    //a_reg2 <= a_reg;
    //b_reg2 <= b_reg;
    //cin_reg2 <= cin_reg;
  end
  
  half_adder half_adder_1(
    .clk(clk),
    .a(a),
    .b(b),
    .sum(sum1),
    .carry(carry1)
  );

  half_adder half_adder_2(
    .clk(clk),
    .a(sum1),
    .b(cin_reg),
    .sum(sum2),
    .carry(carry2)
  );
  
  always @(posedge clk) begin
    carry1_delayed <= carry1;
    sum <= sum2;
  	cout <= carry1_delayed | carry2;
  end  
endmodule


