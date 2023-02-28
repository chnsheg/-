`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/04 10:34:35
// Design Name: 
// Module Name: swdio_tri_buf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module swdio_tri_buf(
    input swd_o,
    output swd_i,
    input swd_oe,
    
    inout swd_io
    );
    
    //原语
    IOBUF swd_iobuf_inst(
        .O(swd_i),
        .I(swd_o),
        .IO(swd_io),
        
        .T(~swd_oe)//T=1：片外到片内，0：片内到片外
    );
endmodule
