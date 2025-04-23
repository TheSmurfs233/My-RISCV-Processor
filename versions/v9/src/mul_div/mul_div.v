module mul_div (
    input  wire clk,
    output wire o 
);

wire [31:0] A, B;
wire [63:0] P;
assign A = 32'h00000001; // Example input for A
assign B = 32'h00000002; // Example input for B
assign o = P[0]; // Example output assignment
mult u_mult_0 (
  .CLK(clk),  // input wire CLK
  .A(A),  // input wire [31 : 0] A
  .B(B),  // input wire [31 : 0] B
  .P(P)  // output wire [63 : 0] P
);

endmodule //mul_div