`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/04 10:37:50
// Design Name: 
// Module Name: ARM_SOC_TOP
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


module SOC_TOP_V2#(
    parameter SimPresent = 0
)   (
 // ????????��
    input                 CLK125m       ,
    input                 reset_n       ,

    // SWD
    inout                 SWDIO        ,
    input                 SWCLK        ,

    // UART
    output                TXD          ,
    input                 RXD          ,
    
    // key
    input                 KEY          ,
    
    //GPIO-User expansion ports
    inout  wire [15:0]   EXP           ,// I/O expansion port
    // LED
    output [3:0]          ledOut
    );
//------------------------------------------------------------------------------
// CLOCK
//------------------------------------------------------------------------------
//clk_div_IP CPU CLOCK
wire 				fclk;
  clk_wiz_0 Global_clk
   (
    // Clock out ports
    .clk_out1(fclk),     // output clk_out1
    // Status and control signals
    .resetn(reset_n), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(CLK125m));      // input clk_in1

//------------------------------------------------------------------------------
// GLOBAL BUF
//------------------------------------------------------------------------------

wire            clk;
wire            swck;

generate 
    if(SimPresent) begin : SimClock
        assign swck = SWCLK;
        assign clk  = CLK125m;
    end 
    else begin : SynClock
        BUFG sw_clk(
            .I     (SWCLK),
            .O     (swck)
        );

        BUFG sys_clk(
            .I     (fclk),
            .O     (clk)
        );                
        end    
endgenerate         
    
//DEBUG   
wire            SWDO;
wire            SWDOEN;
wire            SWDI; 
    swdio_tri_buf swdio_tri_buf_0(
    .swd_o(SWDO),
    .swd_i(SWDI),
    .swd_oe(SWDOEN),//SWDOEN=0?????????1?????????
    
    .swd_io(SWDIO)
    );
    
//------------------------------------------------------------------------------
// RESET(simplified)
//------------------------------------------------------------------------------    
wire  SYSRESETREQ;
reg   cpuresetn;

always @(posedge clk or negedge reset_n)begin
    if (~reset_n) 
        cpuresetn <= 1'b0;
    else if (SYSRESETREQ) 
        cpuresetn <= 1'b0;
    else 
        cpuresetn <= 1'b1;
end

wire SLEEPing;    

//------------------------------------------------------------------------------
// DEBUG CONFIG
//------------------------------------------------------------------------------
wire CDBGPWRUPREQ;
reg  CDBGPWRUPACK;

always @(posedge clk or negedge reset_n)begin
    if (~reset_n) 
        CDBGPWRUPACK <= 1'b0;
    else 
        CDBGPWRUPACK <= CDBGPWRUPREQ;
end

//------------------------------------------------------------------------------
// INTERRUPT 
//------------------------------------------------------------------------------
wire [239:0] IRQ;

//------------------------------------------------------------------------------
// CORE BUS
//------------------------------------------------------------------------------

// CPU I-Code 
wire    [31:0]  HADDRI;
wire    [1:0]   HTRANSI;
wire    [2:0]   HSIZEI;
wire    [2:0]   HBURSTI;
wire    [3:0]   HPROTI;
wire    [31:0]  HRDATAI;
wire            HREADYI;
wire    [1:0]   HRESPI;

// CPU D-Code 
wire    [31:0]  HADDRD;
wire    [1:0]   HTRANSD;
wire    [2:0]   HSIZED;
wire    [2:0]   HBURSTD;
wire    [3:0]   HPROTD;
wire    [31:0]  HWDATAD;
wire            HWRITED;
wire    [31:0]  HRDATAD;
wire            HREADYD;
wire    [1:0]   HRESPD;
wire    [1:0]   HMASTERD;

// CPU System bus 
wire    [31:0]  HADDRS;
wire    [1:0]   HTRANSS;
wire            HWRITES;
wire    [2:0]   HSIZES;
wire    [31:0]  HWDATAS;
wire    [2:0]   HBURSTS;
wire    [3:0]   HPROTS;
wire            HREADYS;
wire    [31:0]  HRDATAS;
wire    [1:0]   HRESPS;
wire    [1:0]   HMASTERS;
wire            HMASTERLOCKS;

//------------------------------------------------------------------------------
// Cortex-M3 processor 
//------------------------------------------------------------------------------

cortexm3ds_logic ulogic(
    // PMU
    .ISOLATEn             ( 1'b1 ),
    .RETAINn              ( 1'b1 ),

    // RESETS
    .PORESETn             ( reset_n     ),
    .SYSRESETn            ( cpuresetn   ),
    .SYSRESETREQ          ( SYSRESETREQ ),
    .RSTBYPASS            ( 1'b0        ),
    .CGBYPASS             ( 1'b0        ),
    .SE                   ( 1'b0        ),

    // CLOCKS
    .FCLK                 ( clk  ),
    .HCLK                 ( clk  ),
    .TRACECLKIN           ( 1'b0 ),

    // SYSTICK  
    .STCLK                (1'b0),
    .STCALIB              (26'b0),
    .AUXFAULT             (32'b0),
//    .STCLK                ( 1'b1                      ),                                   
//    .STCALIB              ( {1'b1, 1'b0, 24'h003D08F} ),// [23:0] -> ???10ms???????????????????
//    .AUXFAULT             ( 32'b0                     ),   

    // CONFIG - SYSTEM
    .BIGEND               ( 1'b0 ),
    .DNOTITRANS           ( 1'b1 ),
    
    // SWJDAP
    .nTRST                ( 1'b1         ),
    .SWDITMS              ( SWDI         ),
    .SWCLKTCK             ( swck         ),
    .TDI                  ( 1'b0         ),
    .CDBGPWRUPACK         ( CDBGPWRUPACK ),
    .CDBGPWRUPREQ         ( CDBGPWRUPREQ ),
    .SWDO                 ( SWDO         ),
    .SWDOEN               ( SWDOEN       ),

    // IRQS
    .INTISR               ( IRQ  ),
    .INTNMI               ( 1'b0 ),
    
    // I-CODE BUS
    .HREADYI              ( HREADYI ),
    .HRDATAI              ( HRDATAI ),
    .HRESPI               ( HRESPI  ),
    .IFLUSH               ( 1'b0    ),
    .HADDRI               ( HADDRI  ),
    .HTRANSI              ( HTRANSI ),
    .HSIZEI               ( HSIZEI  ),
    .HBURSTI              ( HBURSTI ),
    .HPROTI               ( HPROTI  ),

    // D-CODE BUS
    .HREADYD              ( HREADYD  ),
    .HRDATAD              ( HRDATAD  ),
    .HRESPD               ( HRESPD   ),
    .EXRESPD              ( 1'b0     ),
    .HADDRD               ( HADDRD   ),
    .HTRANSD              ( HTRANSD  ),
    .HSIZED               ( HSIZED   ),
    .HBURSTD              ( HBURSTD  ),
    .HPROTD               ( HPROTD   ),
    .HWDATAD              ( HWDATAD  ),
    .HWRITED              ( HWRITED  ),
    .HMASTERD             ( HMASTERD ),

    // SYSTEM BUS
    .HREADYS              ( HREADYS      ),
    .HRDATAS              ( HRDATAS      ),
    .HRESPS               ( HRESPS       ),
    .EXRESPS              ( 1'b0         ),
    .HADDRS               ( HADDRS       ),
    .HTRANSS              ( HTRANSS      ),
    .HSIZES               ( HSIZES       ),
    .HBURSTS              ( HBURSTS      ),
    .HPROTS               ( HPROTS       ),
    .HWDATAS              ( HWDATAS      ),
    .HWRITES              ( HWRITES      ),
    .HMASTERS             ( HMASTERS     ),
    .HMASTLOCKS           ( HMASTERLOCKS ),

    // SLEEP
    .RXEV                 ( 1'b0     ),
    .SLEEPHOLDREQn        ( 1'b1     ),
    .SLEEPING             ( SLEEPing ),
    
    // EXTERNAL DEBUG REQUEST
    .EDBGRQ               ( 1'b0 ),
    .DBGRESTART           ( 1'b0 ),
     
    // DAP HMASTER OVERRIDE 
    .FIXMASTERTYPE        ( 1'b0 ),
 
    // WIC 
    .WICENREQ             ( 1'b0 ),
 
    // TIMESTAMP INTERFACE 
    .TSVALUEB             ( 48'b0 ),

    // CONFIG - DEBUG
    .DBGEN                ( 1'b1 ),
    .NIDEN                ( 1'b1 ),
    .MPUDISABLE           ( 1'b0 )
);

//------------------------------------------------------------------------------
// AHB L1 ???????
// S0:Dbus      S1:Ibus     S2:Sysbus        S3:DMA     S4:RESERVED
// M0:ITCM      M1:DTCM     M2:APB_Bridge   M3:default  M4:AHB_sync
// S0 -> M0, 
// S1 -> M0, 
// S2 -> M1, M2, M3, M4, 
// S3 -> M1, M3, M4, 
// S4 -> M1, M3, M4,
//------------------------------------------------------------------------------

//DMA MASTER
wire    [31:0] HADDRDM;
wire    [1:0]  HTRANSDM;
wire           HWRITEDM;
wire    [2:0]  HSIZEDM;
wire    [31:0] HWDATADM;
wire    [2:0]  HBURSTDM;
wire    [3:0]  HPROTDM;
wire           HREADYDM;
wire    [31:0] HRDATADM;
wire    [1:0]  HRESPDM;
wire    [1:0]  HMASTERDM;
wire           HMASTERLOCKDM;

assign  HADDRDM         =   32'b0;
assign  HTRANSDM        =   2'b0;
assign  HWRITEDM        =   1'b0;
assign  HSIZEDM         =   3'b0;
assign  HWDATADM        =   32'b0;
assign  HBURSTDM        =   3'b0;
assign  HPROTDM         =   4'b0;
assign  HMASTERDM       =   2'b0;
assign  HMASTERLOCKDM   =   1'b0;


//RESERVED  MASTER
wire    [31:0] HADDRR;
wire    [1:0]  HTRANSR;
wire           HWRITER;
wire    [2:0]  HSIZER;
wire    [31:0] HWDATAR;
wire    [2:0]  HBURSTR;
wire    [3:0]  HPROTR;
wire           HREADYR;
wire    [31:0] HRDATAR;
wire    [1:0]  HRESPR;
wire    [1:0]  HMASTERR;
wire           HMASTERLOCKR;

assign  HADDRR         =   32'b0;
assign  HTRANSR        =   2'b0;
assign  HWRITER        =   1'b0;
assign  HSIZER         =   3'b0;
assign  HWDATAR        =   32'b0;
assign  HBURSTR        =   3'b0;
assign  HPROTR         =   4'b0;
assign  HMASTERR       =   2'b0;
assign  HMASTERLOCKR   =   1'b0;

//--------------------------------------------
wire    [31:0] HADDR_AHBL1P0;
wire    [1:0]  HTRANS_AHBL1P0;
wire           HWRITE_AHBL1P0;
wire    [2:0]  HSIZE_AHBL1P0;
wire    [31:0] HWDATA_AHBL1P0;
wire    [2:0]  HBURST_AHBL1P0;
wire    [3:0]  HPROT_AHBL1P0;
wire           HREADY_AHBL1P0;
wire    [31:0] HRDATA_AHBL1P0;
wire    [1:0]  HRESP_AHBL1P0;
wire           HREADYOUT_AHBL1P0;
wire           HSEL_AHBL1P0;
wire    [1:0]  HMASTER_AHBL1P0;
wire           HMASTERLOCK_AHBL1P0;

wire    [31:0] HADDR_AHBL1P1;
wire    [1:0]  HTRANS_AHBL1P1;
wire           HWRITE_AHBL1P1;
wire    [2:0]  HSIZE_AHBL1P1;
wire    [31:0] HWDATA_AHBL1P1;
wire    [2:0]  HBURST_AHBL1P1;
wire    [3:0]  HPROT_AHBL1P1;
wire           HREADY_AHBL1P1;
wire    [31:0] HRDATA_AHBL1P1;
wire    [1:0]  HRESP_AHBL1P1;
wire           HREADYOUT_AHBL1P1;
wire           HSEL_AHBL1P1;
wire    [1:0]  HMASTER_AHBL1P1;
wire           HMASTERLOCK_AHBL1P1;

wire    [31:0] HADDR_AHBL1P2;
wire    [1:0]  HTRANS_AHBL1P2;
wire           HWRITE_AHBL1P2;
wire    [2:0]  HSIZE_AHBL1P2;
wire    [31:0] HWDATA_AHBL1P2;
wire    [2:0]  HBURST_AHBL1P2;
wire    [3:0]  HPROT_AHBL1P2;
wire           HREADY_AHBL1P2;
wire    [31:0] HRDATA_AHBL1P2;
wire    [1:0]  HRESP_AHBL1P2;
wire           HREADYOUT_AHBL1P2;
wire           HSEL_AHBL1P2;
wire    [1:0]  HMASTER_AHBL1P2;
wire           HMASTERLOCK_AHBL1P2;

wire    [31:0]  HADDR_AHBL1P3;
wire    [1:0]   HTRANS_AHBL1P3;
wire            HWRITE_AHBL1P3;
wire    [2:0]   HSIZE_AHBL1P3;
wire    [31:0]  HWDATA_AHBL1P3;
wire    [2:0]   HBURST_AHBL1P3;
wire    [3:0]   HPROT_AHBL1P3;
wire            HREADY_AHBL1P3;
wire    [31:0]  HRDATA_AHBL1P3;
wire    [1:0]   HRESP_AHBL1P3;
wire            HREADYOUT_AHBL1P3;
wire            HSEL_AHBL1P3;
wire    [1:0]   HMASTER_AHBL1P3;
wire            HMASTERLOCK_AHBL1P3;

wire    [31:0]  HADDR_AHBL1P4;
wire    [1:0]   HTRANS_AHBL1P4;
wire            HWRITE_AHBL1P4;
wire    [2:0]   HSIZE_AHBL1P4;
wire    [31:0]  HWDATA_AHBL1P4;
wire    [2:0]   HBURST_AHBL1P4;
wire    [3:0]   HPROT_AHBL1P4;
wire            HREADY_AHBL1P4;
wire    [31:0]  HRDATA_AHBL1P4;
wire    [1:0]   HRESP_AHBL1P4;
wire            HREADYOUT_AHBL1P4;
wire            HSEL_AHBL1P4;
wire    [1:0]   HMASTER_AHBL1P4;
wire            HMASTERLOCK_AHBL1P4;

L1AhbMtx    u_L1AhbMtx(
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),

    .REMAP                              (4'b0),
    //I_bus
    .HSELS1                             (1'b1),
    .HADDRS1                            (HADDRI),
    .HTRANSS1                           (HTRANSI),
    .HWRITES1                           (1'b0),
    .HSIZES1                            (HSIZEI),
    .HBURSTS1                           (HBURSTI),
    .HPROTS1                            (HPROTI),
    .HMASTERS1                          (4'b0),
    .HWDATAS1                           (32'b0),
    .HMASTLOCKS1                        (1'b0),
    .HREADYS1                           (HREADYI),
    .HRDATAS1                           (HRDATAI),
    .HREADYOUTS1                        (HREADYI),
    .HRESPS1                            (HRESPI),
    
    //D_bus
    .HSELS0                             (1'b1),
    .HADDRS0                            (HADDRD),
    .HTRANSS0                           (HTRANSD),
    .HWRITES0                           (HWRITED),
    .HSIZES0                            (HSIZED),
    .HBURSTS0                           (HBURSTD),
    .HPROTS0                            (HPROTD),
    .HMASTERS0                          ({2'b0,HMASTERD}),
    .HWDATAS0                           (HWDATAD),
    .HMASTLOCKS0                        (1'b0),
    .HREADYS0                           (HREADYD),
    .HREADYOUTS0                        (HREADYD),
    .HRESPS0                            (HRESPD),
    .HRDATAS0                           (HRDATAD),
    
    //SYSTEM_bus
    .HSELS2                             (1'b1),
    .HADDRS2                            (HADDRS),
    .HTRANSS2                           (HTRANSS),
    .HWRITES2                           (HWRITES),
    .HSIZES2                            (HSIZES),
    .HBURSTS2                           (HBURSTS),
    .HPROTS2                            (HPROTS),
    .HMASTERS2                          ({2'b0,HMASTERS}),
    .HWDATAS2                           (HWDATAS),
    .HMASTLOCKS2                        (HMASTERLOCKS),
    .HREADYS2                           (HREADYS),
    .HREADYOUTS2                        (HREADYS),
    .HRESPS2                            (HRESPS),
    .HRDATAS2                           (HRDATAS),    

    .HSELS3                             (1'b1),
    .HADDRS3                            (HADDRDM),
    .HTRANSS3                           (HTRANSDM),
    .HWRITES3                           (HWRITEDM),
    .HSIZES3                            (HSIZEDM),
    .HBURSTS3                           (HBURSTDM),
    .HPROTS3                            (HPROTDM),
    .HMASTERS3                          ({2'b0,HMASTERDM}),
    .HWDATAS3                           (HWDATADM),
    .HMASTLOCKS3                        (HMASTERLOCKDM),
    .HREADYS3                           (1'b1),
    .HREADYOUTS3                        (HREADYDM),
    .HRESPS3                            (HRESPDM),
    .HRDATAS3                           (HRDATADM),

    .HSELS4                             (1'b1),
    .HADDRS4                            (HADDRR),
    .HTRANSS4                           (HTRANSR),
    .HWRITES4                           (HWRITER),
    .HSIZES4                            (HSIZER),
    .HBURSTS4                           (HBURSTR),
    .HPROTS4                            (HPROTR),
    .HMASTERS4                          ({2'b0,HMASTERR}),
    .HWDATAS4                           (HWDATAR),
    .HMASTLOCKS4                        (HMASTERLOCKR),
    .HREADYS4                           (1'b1),
    .HREADYOUTS4                        (HREADYR),
    .HRESPS4                            (HRESPR),
    .HRDATAS4                           (HRDATAR),

    .HSELM0                             (HSEL_AHBL1P0),
    .HADDRM0                            (HADDR_AHBL1P0),
    .HTRANSM0                           (HTRANS_AHBL1P0),
    .HWRITEM0                           (HWRITE_AHBL1P0),
    .HSIZEM0                            (HSIZE_AHBL1P0),
    .HBURSTM0                           (HBURST_AHBL1P0),
    .HPROTM0                            (HPROT_AHBL1P0),
    .HMASTERM0                          (HMASTER_AHBL1P0),
    .HWDATAM0                           (HWDATA_AHBL1P0),
    .HMASTLOCKM0                        (HMASTERLOCK_AHBL1P0),
    .HREADYMUXM0                        (HREADY_AHBL1P0),
    .HRDATAM0                           (HRDATA_AHBL1P0),
    .HREADYOUTM0                        (HREADYOUT_AHBL1P0),
    .HRESPM0                            (HRESP_AHBL1P0),

    .HSELM1                             (HSEL_AHBL1P1),
    .HADDRM1                            (HADDR_AHBL1P1),
    .HTRANSM1                           (HTRANS_AHBL1P1),
    .HWRITEM1                           (HWRITE_AHBL1P1),
    .HSIZEM1                            (HSIZE_AHBL1P1),
    .HBURSTM1                           (HBURST_AHBL1P1),
    .HPROTM1                            (HPROT_AHBL1P1),
    .HMASTERM1                          (HMASTER_AHBL1P1),
    .HWDATAM1                           (HWDATA_AHBL1P1),
    .HMASTLOCKM1                        (HMASTERLOCK_AHBL1P1),
    .HREADYMUXM1                        (HREADY_AHBL1P1),
    .HRDATAM1                           (HRDATA_AHBL1P1),
    .HREADYOUTM1                        (HREADYOUT_AHBL1P1),
    .HRESPM1                            (HRESP_AHBL1P1),

    .HSELM2                             (HSEL_AHBL1P2),
    .HADDRM2                            (HADDR_AHBL1P2),
    .HTRANSM2                           (HTRANS_AHBL1P2),
    .HWRITEM2                           (HWRITE_AHBL1P2),
    .HSIZEM2                            (HSIZE_AHBL1P2),
    .HBURSTM2                           (HBURST_AHBL1P2),
    .HPROTM2                            (HPROT_AHBL1P2),
    .HMASTERM2                          (HMASTER_AHBL1P2),
    .HWDATAM2                           (HWDATA_AHBL1P2),
    .HMASTLOCKM2                        (HMASTERLOCK_AHBL1P2),
    .HREADYMUXM2                        (HREADY_AHBL1P2),
    .HRDATAM2                           (HRDATA_AHBL1P2),
    .HREADYOUTM2                        (HREADYOUT_AHBL1P2),
    .HRESPM2                            (HRESP_AHBL1P2),

    .HSELM3                             (HSEL_AHBL1P3),
    .HADDRM3                            (HADDR_AHBL1P3),
    .HTRANSM3                           (HTRANS_AHBL1P3),
    .HWRITEM3                           (HWRITE_AHBL1P3),
    .HSIZEM3                            (HSIZE_AHBL1P3),
    .HBURSTM3                           (HBURST_AHBL1P3),
    .HPROTM3                            (HPROT_AHBL1P3),
    .HMASTERM3                          (HMASTER_AHBL1P3),
    .HWDATAM3                           (HWDATA_AHBL1P3),
    .HMASTLOCKM3                        (HMASTERLOCK_AHBL1P3),
    .HREADYMUXM3                        (HREADY_AHBL1P3),
    .HRDATAM3                           (HRDATA_AHBL1P3),
    .HREADYOUTM3                        (HREADYOUT_AHBL1P3),
    .HRESPM3                            (HRESP_AHBL1P3),

    .HSELM4                             (HSEL_AHBL1P4),
    .HADDRM4                            (HADDR_AHBL1P4),
    .HTRANSM4                           (HTRANS_AHBL1P4),
    .HWRITEM4                           (HWRITE_AHBL1P4),
    .HSIZEM4                            (HSIZE_AHBL1P4),
    .HBURSTM4                           (HBURST_AHBL1P4),
    .HPROTM4                            (HPROT_AHBL1P4),
    .HMASTERM4                          (HMASTER_AHBL1P4),
    .HWDATAM4                           (HWDATA_AHBL1P4),
    .HMASTLOCKM4                        (HMASTERLOCK_AHBL1P4),
    .HREADYMUXM4                        (HREADY_AHBL1P4),
    .HRDATAM4                           (HRDATA_AHBL1P4),
    .HREADYOUTM4                        (HREADYOUT_AHBL1P4),
    .HRESPM4                            (HRESP_AHBL1P4),

    .SCANENABLE                         (1'b0),
    .SCANINHCLK                         (1'b0),
    .SCANOUTHCLK                        ()
);

//-----------------------------------------------------------
wire    [31:0] HADDR_AHBL2M;
wire    [1:0]  HTRANS_AHBL2M;
wire           HWRITE_AHBL2M;
wire    [2:0]  HSIZE_AHBL2M;
wire    [31:0] HWDATA_AHBL2M;
wire    [2:0]  HBURST_AHBL2M;
wire    [3:0]  HPROT_AHBL2M;
wire           HREADY_AHBL2M;
wire    [31:0] HRDATA_AHBL2M;
wire    [1:0]  HRESP_AHBL2M;
wire           HREADYOUT_AHBL2M;
wire           HSEL_AHBL2M;
wire    [1:0]  HMASTER_AHBL2M;
wire           HMASTERLOCK_AHBL2M;

cmsdk_ahb_to_ahb_sync #(
    .AW                                 (32),
    .DW                                 (32),
    .MW                                 (2),
    .BURST                              (1)
)   AhbBridge   (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSELS                              (HSEL_AHBL1P4),
    .HADDRS                             (HADDR_AHBL1P4),
    .HTRANSS                            (HTRANS_AHBL1P4),
    .HSIZES                             (HSIZE_AHBL1P4),
    .HWRITES                            (HWRITE_AHBL1P4),
    .HREADYS                            (HREADY_AHBL1P4),
    .HPROTS                             (HPROT_AHBL1P4),
    .HMASTERS                           (HMASTER_AHBL1P4),
    .HMASTLOCKS                         (HMASTERLOCK_AHBL1P4),
    .HWDATAS                            (HWDATA_AHBL1P4),
    .HBURSTS                            (HBURST_AHBL1P4),
    .HREADYOUTS                         (HREADYOUT_AHBL1P4),
    .HRESPS                             (HRESP_AHBL1P4[0]),
    .HRDATAS                            (HRDATA_AHBL1P4),
    
    .HADDRM                             (HADDR_AHBL2M),
    .HTRANSM                            (HTRANS_AHBL2M),
    .HSIZEM                             (HSIZE_AHBL2M),
    .HWRITEM                            (HWRITE_AHBL2M),
    .HPROTM                             (HPROT_AHBL2M),
    .HMASTERM                           (HMASTER_AHBL2M),
    .HMASTLOCKM                         (HMASTERLOCK_AHBL2M),
    .HWDATAM                            (HWDATA_AHBL2M),
    .HBURSTM                            (HBURST_AHBL2M),
    .HREADYM                            (HREADYOUT_AHBL2M),
    .HRESPM                             (HRESP_AHBL2M[0]),
    .HRDATAM                            (HRDATA_AHBL2M)

);

assign  HRESP_AHBL1P4[1]    =   1'b0;

//----------------------------------------------------
wire    [31:0] HADDR_AHBL2P0;
wire    [1:0]  HTRANS_AHBL2P0;
wire           HWRITE_AHBL2P0;
wire    [2:0]  HSIZE_AHBL2P0;
wire    [31:0] HWDATA_AHBL2P0;
wire    [2:0]  HBURST_AHBL2P0;
wire    [3:0]  HPROT_AHBL2P0;
wire           HREADY_AHBL2P0;
wire           HREADYOUT_AHBL2P0;
wire           HSEL_AHBL2P0;
wire    [31:0] HRDATA_AHBL2P0;
wire    [1:0]  HRESP_AHBL2P0;
wire    [1:0]  HMASTER_AHBL2P0;
wire           HMASTERLOCK_AHBL2P0;

wire    [31:0] HADDR_AHBL2P1;
wire    [1:0]  HTRANS_AHBL2P1;
wire           HWRITE_AHBL2P1;
wire    [2:0]  HSIZE_AHBL2P1;
wire    [31:0] HWDATA_AHBL2P1;
wire    [2:0]  HBURST_AHBL2P1;
wire    [3:0]  HPROT_AHBL2P1;
wire           HREADY_AHBL2P1;
wire           HREADYOUT_AHBL2P1;
wire           HSEL_AHBL2P1;
wire    [31:0] HRDATA_AHBL2P1;
wire    [1:0]  HRESP_AHBL2P1;
wire    [1:0]  HMASTER_AHBL2P1;
wire           HMASTERLOCK_AHBL2P1;

L2AhbMtx    u_L2AhbMtx(
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),

    .REMAP                              (4'b0),

    .HSELS0                             (1'b1),
    .HADDRS0                            (HADDR_AHBL2M),
    .HTRANSS0                           (HTRANS_AHBL2M),
    .HWRITES0                           (HWRITE_AHBL2M),
    .HSIZES0                            (HSIZE_AHBL2M),
    .HBURSTS0                           (HBURST_AHBL2M),
    .HPROTS0                            (HPROT_AHBL2M),
    .HMASTERS0                          (HMASTER_AHBL2M),
    .HWDATAS0                           (HWDATA_AHBL2M),
    .HMASTLOCKS0                        (HMASTERLOCK_AHBL2M),
    .HREADYS0                           (HREADYOUT_AHBL2M),
    .HRDATAS0                           (HRDATA_AHBL2M),
    .HREADYOUTS0                        (HREADYOUT_AHBL2M),
    .HRESPS0                            (HRESP_AHBL2M),

    .HSELM0                             (HSEL_AHBL2P0),
    .HADDRM0                            (HADDR_AHBL2P0),
    .HTRANSM0                           (HTRANS_AHBL2P0),
    .HWRITEM0                           (HWRITE_AHBL2P0),
    .HSIZEM0                            (HSIZE_AHBL2P0),
    .HBURSTM0                           (HBURST_AHBL2P0),
    .HPROTM0                            (HPROT_AHBL2P0),
    .HMASTERM0                          (HMASTER_AHBL2P0),
    .HWDATAM0                           (HWDATA_AHBL2P0),
    .HMASTLOCKM0                        (HMASTERLOCK_AHBL2P0),
    .HREADYMUXM0                        (HREADY_AHBL2P0),
    .HRDATAM0                           (HRDATA_AHBL2P0),
    .HREADYOUTM0                        (HREADYOUT_AHBL2P0),
    .HRESPM0                            (HRESP_AHBL2P0),

    .HSELM1                             (HSEL_AHBL2P1),
    .HADDRM1                            (HADDR_AHBL2P1),
    .HTRANSM1                           (HTRANS_AHBL2P1),
    .HWRITEM1                           (HWRITE_AHBL2P1),
    .HSIZEM1                            (HSIZE_AHBL2P1),
    .HBURSTM1                           (HBURST_AHBL2P1),
    .HPROTM1                            (HPROT_AHBL2P1),
    .HMASTERM1                          (HMASTER_AHBL2P1),
    .HWDATAM1                           (HWDATA_AHBL2P1),
    .HMASTLOCKM1                        (HMASTERLOCK_AHBL2P1),
    .HREADYMUXM1                        (HREADY_AHBL2P1),
    .HRDATAM1                           (HRDATA_AHBL2P1),
    .HREADYOUTM1                        (HREADYOUT_AHBL2P1),
    .HRESPM1                            (HRESP_AHBL2P1),

    .SCANENABLE                         (1'b0),
    .SCANINHCLK                         (1'b0),
    .SCANOUTHCLK                        ()
);


wire    [15:0]  PADDR;    
wire            PENABLE;  
wire            PWRITE;   
wire    [3:0]   PSTRB;    
wire    [2:0]   PPROT;    
wire    [31:0]  PWDATA;   
wire            PSEL;     
wire            APBACTIVE;                  
wire    [31:0]  PRDATA;   
wire            PREADY;  
wire            PSLVERR; 

cmsdk_ahb_to_apb #(
    .ADDRWIDTH                          (16),
    .REGISTER_RDATA                     (1),
    .REGISTER_WDATA                     (1)
)    ApbBridge  (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .PCLKEN                             (1'b1),
    .HSEL                               (HSEL_AHBL1P2),
    .HADDR                              (HADDR_AHBL1P2),
    .HTRANS                             (HTRANS_AHBL1P2),
    .HSIZE                              (HSIZE_AHBL1P2),
    .HPROT                              (HPROT_AHBL1P2),
    .HWRITE                             (HWRITE_AHBL1P2),
    .HREADY                             (HREADY_AHBL1P2),
    .HWDATA                             (HWDATA_AHBL1P2),
    .HREADYOUT                          (HREADYOUT_AHBL1P2),
    .HRDATA                             (HRDATA_AHBL1P2),
    .HRESP                              (HRESP_AHBL1P2[0]),      
    
    // APB  
    .PADDR                              (PADDR),
    .PENABLE                            (PENABLE),
    .PWRITE                             (PWRITE),
    .PSTRB                              (PSTRB),
    .PPROT                              (PPROT),
    .PWDATA                             (PWDATA),
    .PSEL                               (PSEL),
    .APBACTIVE                          (APBACTIVE),
    .PRDATA                             (PRDATA),
    .PREADY                             (PREADY),
    .PSLVERR                            (PSLVERR)                      
);

assign  HRESP_AHBL1P2[1]    =   1'b0;

//----------------------------------------------------
wire            PSEL_APBP0;
wire            PREADY_APBP0;
wire    [31:0]  PRDATA_APBP0;
wire            PSLVERR_APBP0;

wire            PSEL_APBP1;
wire            PREADY_APBP1;
wire    [31:0]  PRDATA_APBP1;
wire            PSLVERR_APBP1;

wire            PSEL_APBP2;
wire            PREADY_APBP2;
wire    [31:0]  PRDATA_APBP2;
wire            PSLVERR_APBP2;

cmsdk_apb_slave_mux #(
    .PORT0_ENABLE                       (1),
    .PORT1_ENABLE                       (1),
    .PORT2_ENABLE                       (1),
    .PORT3_ENABLE                       (0),
    .PORT4_ENABLE                       (0),
    .PORT5_ENABLE                       (0),
    .PORT6_ENABLE                       (0),
    .PORT7_ENABLE                       (0),
    .PORT8_ENABLE                       (0),
    .PORT9_ENABLE                       (0),
    .PORT10_ENABLE                      (0),
    .PORT11_ENABLE                      (0),
    .PORT12_ENABLE                      (0),
    .PORT13_ENABLE                      (0),
    .PORT14_ENABLE                      (0),
    .PORT15_ENABLE                      (0)
)   ApbSystem   (
    .DECODE4BIT                         (PADDR[15:12]),
    .PSEL                               (PSEL),
    // UART
    .PSEL0                              (PSEL_APBP0),
    .PREADY0                            (PREADY_APBP0),
    .PRDATA0                            (PRDATA_APBP0),
    .PSLVERR0                           (PSLVERR_APBP0),
    
    .PSEL1                              (PSEL_APBP1),
    .PREADY1                            (PREADY_APBP1),
    .PRDATA1                            (PRDATA_APBP1),
    .PSLVERR1                           (PSLVERR_APBP1),

    .PSEL2                              (PSEL_APBP2),
    .PREADY2                            (PREADY_APBP2),
    .PRDATA2                            (PRDATA_APBP2),
    .PSLVERR2                           (PSLVERR_APBP2),

    .PSEL3                              (),
    .PREADY3                            (1'b1),
    .PRDATA3                            (32'b0),
    .PSLVERR3                           (1'b0),

    .PSEL4                              (),
    .PREADY4                            (1'b1),
    .PRDATA4                            (32'b0),
    .PSLVERR4                           (1'b0),

    .PSEL5                              (),
    .PREADY5                            (1'b1),
    .PRDATA5                            (32'b0),
    .PSLVERR5                           (1'b0),

    .PSEL6                              (),
    .PREADY6                            (1'b1),
    .PRDATA6                            (32'b0),
    .PSLVERR6                           (1'b0),

    .PSEL7                              (),
    .PREADY7                            (1'b1),
    .PRDATA7                            (32'b0),
    .PSLVERR7                           (1'b0),

    .PSEL8                              (),
    .PREADY8                            (1'b1),
    .PRDATA8                            (32'b0),
    .PSLVERR8                           (1'b0),

    .PSEL9                              (),
    .PREADY9                            (1'b1),
    .PRDATA9                            (32'b0),
    .PSLVERR9                           (1'b0),

    .PSEL10                             (),
    .PREADY10                           (1'b1),
    .PRDATA10                           (32'b0),
    .PSLVERR10                          (1'b0),

    .PSEL11                             (),
    .PREADY11                           (1'b1),
    .PRDATA11                           (32'b0),
    .PSLVERR11                          (1'b0),

    .PSEL12                             (),
    .PREADY12                           (1'b1),
    .PRDATA12                           (32'b0),
    .PSLVERR12                          (1'b0),
    
    .PSEL13                             (),
    .PREADY13                           (1'b1),
    .PRDATA13                           (32'b0),
    .PSLVERR13                          (1'b0),

    .PSEL14                             (),
    .PREADY14                           (1'b1),
    .PRDATA14                           (32'b0),
    .PSLVERR14                          (1'b0),

    .PSEL15                             (),
    .PREADY15                           (1'b1),
    .PRDATA15                           (32'b0),
    .PSLVERR15                          (1'b0),

    .PREADY                             (PREADY),
    .PRDATA                             (PRDATA),
    .PSLVERR                            (PSLVERR)

);

//------------------------------------------------------------------------------
// AHB ITCM 
//------------------------------------------------------------------------------

wire    [13:0]  ITCMADDR;
wire    [31:0]  ITCMRDATA,ITCMWDATA;
wire    [3:0]   ITCMWRITE;
wire            ITCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   AhbItcm (
    // AHB signals
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL1P0),
    .HREADY                             (HREADY_AHBL1P0),
    .HTRANS                             (HTRANS_AHBL1P0),
    .HSIZE                              (HSIZE_AHBL1P0),
    .HWRITE                             (HWRITE_AHBL1P0),
    .HADDR                              (HADDR_AHBL1P0),
    .HWDATA                             (HWDATA_AHBL1P0),
    .HREADYOUT                          (HREADYOUT_AHBL1P0),
    .HRESP                              (HRESP_AHBL1P0[0]),
    .HRDATA                             (HRDATA_AHBL1P0),
    
    // SRAM signals
    .SRAMRDATA                          (ITCMRDATA),
    .SRAMADDR                           (ITCMADDR),
    .SRAMWEN                            (ITCMWRITE),
    .SRAMWDATA                          (ITCMWDATA),
    .SRAMCS                             (ITCMCS)
);

assign  HRESP_AHBL1P0[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)
)   ITCM    (
    .CLK                                (clk),
    .ADDR                               (ITCMADDR),
    .WDATA                              (ITCMWDATA),
    .WREN                               (ITCMWRITE),
    .CS                                  (ITCMCS),
    .RDATA                              (ITCMRDATA)
);


//------------------------------------------------------------------------------
// AHB DTCM
//------------------------------------------------------------------------------

wire    [13:0]  DTCMADDR;
wire    [31:0]  DTCMRDATA,DTCMWDATA;
wire    [3:0]   DTCMWRITE;
wire            DTCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   AhbDtcm (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL1P1),
    .HREADY                             (HREADY_AHBL1P1),
    .HTRANS                             (HTRANS_AHBL1P1),
    .HSIZE                              (HSIZE_AHBL1P1),
    .HWRITE                             (HWRITE_AHBL1P1),
    .HADDR                              (HADDR_AHBL1P1),
    .HWDATA                             (HWDATA_AHBL1P1),
    .HREADYOUT                          (HREADYOUT_AHBL1P1),
    .HRESP                              (HRESP_AHBL1P1[0]),
    .HRDATA                             (HRDATA_AHBL1P1),
    .SRAMRDATA                          (DTCMRDATA),
    .SRAMADDR                           (DTCMADDR),
    .SRAMWEN                            (DTCMWRITE),
    .SRAMWDATA                          (DTCMWDATA),
    .SRAMCS                             (DTCMCS)
);
assign  HRESP_AHBL1P1[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)
)   DTCM    (
    .CLK                                (clk),
    .ADDR                               (DTCMADDR),
    .WDATA                              (DTCMWDATA),
    .WREN                               (DTCMWRITE),
    .CS                                 (DTCMCS),
    .RDATA                              (DTCMRDATA)
);

//------------------------------------------------------------------------------
// APB UART
// 0x4000_0000
//------------------------------------------------------------------------------

wire            TXINT;
wire            RXINT;
wire            TXOVRINT;
wire            RXOVRINT;
wire            UARTINT;      

cmsdk_apb_uart UART(
    .PCLK                               (clk),
    .PCLKG                              (clk),
    .PRESETn                            (cpuresetn),
    .PSEL                               (PSEL_APBP0),
    .PADDR                              (PADDR[11:2]),
    .PENABLE                            (PENABLE), 
    .PWRITE                             (PWRITE),
    .PWDATA                             (PWDATA),
    .ECOREVNUM                          (4'b0),
    .PRDATA                             (PRDATA_APBP0),
    .PREADY                             (PREADY_APBP0),
    .PSLVERR                            (PSLVERR_APBP0),
    .RXD                                (RXD),
    .TXD                                (TXD),
//    .TXEN                               (TXEN),
//    .BAUDTICK                           (BAUDTICK),
    .TXINT                              (TXINT),
    .RXINT                              (RXINT),
    .TXOVRINT                           (TXOVRINT),
    .RXOVRINT                           (RXOVRINT),
    .UARTINT                            (UARTINT)
);

//------------------------------------------------------------------------------
// APB LED
// 0x4000_1000
//------------------------------------------------------------------------------
cmsdk_apb3_eg_slave_led #(
    .ADDRWIDTH (12 )
) LED(
    .PCLK      ( clk             ),
    .PRESETn   ( cpuresetn       ),
    .PSEL      ( PSEL_APBP1    ),
    .PADDR     ( PADDR[11:2]     ),
    .PENABLE   ( PENABLE         ),
    .PWRITE    ( PWRITE          ),
    .PWDATA    ( PWDATA          ),
    .ECOREVNUM ( 4'b0            ),
    .PRDATA    ( PRDATA_APBP1  ),
    .PREADY    ( PREADY_APBP1  ),
    .PSLVERR   ( PSLVERR_APBP1 ),

    .ledNumOut ( ledOut       )
);

//------------------------------------------------------------------------------
// APB BUTTON
// 0x4000_2000
//------------------------------------------------------------------------------
wire KEY_IRQ; 
custom_apb_button #(
    .ADDRWIDTH (12 )
) u_custom_apb_button(
    .pclk    ( clk                ),
    .presetn ( cpuresetn          ),
    .psel    ( PSEL_APBP2         ),
    .paddr   ( PADDR[11:2]        ),
    .penable ( PENABLE            ),
    .pwrite  ( PWRITE             ),
    .pwdata  ( PWDATA             ),
    .prdata  ( PRDATA_APBP2       ),
    .pready  ( PREADY_APBP2       ),
    .pslverr ( PSLVERR_APBP2      ),

    .key     ( KEY                ),
    .KEY_IRQ ( KEY_IRQ            )
);
//------------------------------------------------------------------------------
// AHB DEFAULT SLAVE RESERVED FOR DDR
//------------------------------------------------------------------------------

cmsdk_ahb_default_slave Default4DDR(
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL1P3),
    .HTRANS                             (HTRANS_AHBL1P3),
    .HREADY                             (HREADY_AHBL1P3),
    .HREADYOUT                          (HREADYOUT_AHBL1P3),
    .HRESP                              (HRESP_AHBL1P3[0])
);
assign  HRESP_AHBL1P3[1]    =   1'b0;
assign  HRDATA_AHBL1P3      =   32'b0;


//------------------------------------------------------------------------------
// AHB GPIO
//------------------------------------------------------------------------------
wire    [15:0]  PORTIN;
wire    [15:0]  PORTOUT;
wire    [15:0]  PORTEN;
wire    [15:0]  PORTFUNC;
    
wire    [15:0] GPIO_en;
wire    [15:0] GPIO_out;
// --------------------------------------------------------------------
// 3-state buffers
// --------------------------------------------------------------------
genvar i1;
// I/O expansion port
    generate
      for (i1=0;i1<16;i1=i1+1)
        begin: gen_port_3state
        assign EXP[i1] =
          (GPIO_en[i1]) ? GPIO_out[i1] : 1'bz;
       end
    endgenerate

    // --------------------------------------------------------------------
    // Multiplexing Exp signals
    // --------------------------------------------------------------------
    assign PORTIN[15:0] = EXP[15:0];
    
genvar i2;
  generate
      for (i2=0;i2<16;i2=i2+1)
        begin: gen_port_en
       assign GPIO_en[i2]   = ~PORTFUNC[i2]  ? PORTEN[i2]  : 1'b0;
       assign GPIO_out[i2]  = ~PORTFUNC[i2]  ? PORTOUT[i2] : 1'b0; 
       end
    endgenerate
    
wire [15:0]  GPIOINT;
wire  COMBINT;

cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK                (16'hFFFF),
    .ALTERNATE_FUNC_DEFAULT             (16'h0000),
    .BE                                 (0)
)
 GPIO_test(
    .HCLK                              (clk),
    .HRESETn                           (cpuresetn),
    .FCLK                              (clk),
    .HSEL                              (HSEL_AHBL2P0),
    .HREADY                            (HREADY_AHBL2P0),
    .HTRANS                            (HTRANS_AHBL2P0),
    .HSIZE                             (HSIZE_AHBL2P0),
    .HWRITE                            (HWRITE_AHBL2P0),
    .HADDR                             (HADDR_AHBL2P0),
    .HWDATA                            (HWDATA_AHBL2P0),

    .ECOREVNUM                         (4'b0),



    .HREADYOUT                         (HREADYOUT_AHBL2P0),
    .HRESP                             (HRESP_AHBL2P0),
    .HRDATA                            (HRDATA_AHBL2P0),

    .PORTIN                            (PORTIN),  //data input
    
    .PORTOUT                           (PORTOUT),
    .PORTEN                            (PORTEN),
    .PORTFUNC                          (PORTFUNC),

    .GPIOINT                           (GPIOINT),
    .COMBINT                           (COMBINT)

);

//------------------------------------------------------------------------------
// AHB DEFAULT SLAVE RESERVED FOR CAMERA
//------------------------------------------------------------------------------
//cmsdk_ahb_default_slave Default4Camera(
//    .HCLK                               (clk),
//    .HRESETn                            (cpuresetn),
//    .HSEL                               (HSEL_AHBL2P0),
//    .HTRANS                             (HTRANS_AHBL2P0),
//    .HREADY                             (HREADY_AHBL2P0),
//    .HREADYOUT                          (HREADYOUT_AHBL2P0),
//    .HRESP                              (HRESP_AHBL2P0[0])
//);
//assign  HRESP_AHBL2P0[1]    =   1'b0;
//assign  HRDATA_AHBL2P0      =   32'b0;

//------------------------------------------------------------------------------
// AHB DEFAULT SLAVE RESERVED FOR LCD
//------------------------------------------------------------------------------

cmsdk_ahb_default_slave Default4LCD(
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL2P1),
    .HTRANS                             (HTRANS_AHBL2P1),
    .HREADY                             (HREADY_AHBL2P1),
    .HREADYOUT                          (HREADYOUT_AHBL2P1),
    .HRESP                              (HRESP_AHBL2P1[0])
);
assign  HRESP_AHBL2P1[1]    =   1'b0;
assign  HRDATA_AHBL2P1      =   32'b0;

//------------------------------------------------------------------------------
// INTERRUPT 
//------------------------------------------------------------------------------

assign  IRQ     =   {236'b0,KEY_IRQ,TXOVRINT|RXOVRINT,RXINT,TXINT};

ila_0 your_instance_name (
	.clk(clk), // input wire clk


	.probe0(EXP[4]), // input wire [0:0]  probe0  
	.probe1(EXP[5]), // input wire [0:0]  probe1 
	.probe2(EXP[6]), // input wire [0:0]  probe2 
	.probe3(EXP[7]) // input wire [0:0]  probe3
);

endmodule


