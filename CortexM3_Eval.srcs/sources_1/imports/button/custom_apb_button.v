module custom_apb_button #(
	parameter ADDRWIDTH = 12)
	(
	//SYSTEM
	input wire                       pclk,
	input wire                       presetn,
	
	//APB
	input  wire                      psel,
	input  wire [ADDRWIDTH-1:0]      paddr,
	input  wire                      penable,
	input  wire                      pwrite,
	input  wire [31:0]               pwdata,
	output reg  [31:0]               prdata,
	output wire                      pready,
	output wire                      pslverr,
	
	//INTERFACE
	input wire                       key,  

    output reg                       KEY_IRQ     
	
	);
	wire key_pulse,key_edge;
	

  	assign   pready  = 1'b1;	//always ready. Can be customized to support waitstate if required.
  	assign   pslverr = 1'b0;	//alwyas OKAY. Can be customized to support error response if required.

	reg		[31:0]		btn_reg;
	
	always @ (posedge pclk or negedge presetn)
	begin
		if(~presetn) begin
			btn_reg <= 32'h0;
		end else begin
			btn_reg <= {{31{1'b0}},key_pulse}; 
		end
	end	
    //产生中断信号
    always @(posedge pclk or negedge presetn) begin
        if(~presetn) begin
            KEY_IRQ <= 0;
        end else if(key_pulse) begin
            KEY_IRQ <= 1;
        end else
            KEY_IRQ <= 0;
    end

  	always @(posedge pclk or negedge presetn)
	begin
		if (~presetn) begin
			prdata <= 32'h00;
		end else begin
			prdata <= btn_reg;
		end
	end

// 按键消抖
reg [19:0] time_cnt;

reg key_reg;
reg key_reg_next;

reg key_sec;     //延时后检测电平寄存器变量
reg key_sec_next;    

always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        key_reg <= 1'b1;
        key_reg_next <= 1'b1;
    end
    else begin
        key_reg <= key;
        key_reg_next <= key_reg;
    end
end

assign key_edge = key_reg_next & (~key_reg);

always @(posedge pclk or negedge presetn) begin
    if(!presetn)begin
        time_cnt <= 20'b0;
    end
    else if (key_edge) begin
        time_cnt <= 20'b0;
    end
    else if (time_cnt == 20'd999_999) begin
        time_cnt <= 20'b0;    
    end
    else begin
        time_cnt <= time_cnt + 1'b1;
    end
end
 
//延时后检测key，如果按键状态变低产生一个时钟的高脉冲�?�如果按键状态是高的话说明按键无�?
always @(posedge pclk or negedge presetn) begin
     if (!presetn) 
         key_sec <= 1'b1;                
     else if (time_cnt == 20'd999_999)
         key_sec <= key;  
end

always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        key_sec_next <= 1'b1;
    else                   
        key_sec_next <= key_sec;             
end    

assign  key_pulse = key_sec_next & (~key_sec); 

endmodule
 
  