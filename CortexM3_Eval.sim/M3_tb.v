`timescale 1ns / 1ns

module M3_tb(

    );

reg clk;
reg rstn;
reg key;
wire [3:0] led;
SOC_TOP_V2 #(
    .SimPresent (1 )
)
u_SOC(
    .CLK125m(clk),
    .reset_n(rstn),
    .KEY(key),
    .RXD(1'b0),
    .ledOut(led)
);


initial begin
    clk = 1;
    rstn = 0;
    key=0;
    #101
    rstn = 1;
    #100
    key=1;
    #200000000
    key=0;
end

always begin
    #10 clk = ~clk;
end

endmodule
