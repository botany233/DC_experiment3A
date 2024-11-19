module	SEG_display
(
	input		wire			clk			,
	input		wire			rst_n		,
	input		wire	[1:0]	sw			,
	input		wire	[1:0]	key		,
	input		wire	[31:0]	result		,
	input		wire	[31:0]	pc			,
	output	wire	[1:0]	com		,
	output	wire	[7:0]	segs		,
	output	wire	[3:0]	leds		
);

wire			left		;
wire			right		;
wire	[7:0]	display	;
	
debounce	#(500_000)	debounce_left	(clk, rst_n, key[1], left);
debounce	#(500_000)	debounce_right	(clk, rst_n, key[0], right);

control	control_inst
(
	.clk		(clk		)	,
	.rst_n		(rst_n		),
	.sw		(sw		)	,
	.left		(left		),
	.right		(right		),
	.result		(result		),
	.pc			(pc		),
	.display	(display	),
	.leds		(leds		)
);

segment
#(
	.CNT_1ms	(	50_0000)
)
segment_inst
(
	.clk		(clk		)	,
	.rst_n		(rst_n		),
	.display	(display	),
	.com		(com		),
	.segs		(segs		)
);

endmodule	




module	debounce			//消抖模块
#(
	parameter	CNT_10ms	=	500_000
)
(
	input		wire		clk			,
	input		wire		rst_n		,
	input		wire		key_in	,
	output	wire		key_flag	
);

reg	[31:0]	cnt;

//10ms计数器
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt<=0;
	else if(key_in==0)
		cnt<=0;
	else if(cnt==CNT_10ms)
		cnt<=CNT_10ms;
	else
		cnt<=cnt+1;

//按键信号稳定10ms后发出一个有效脉冲
assign	key_flag = (cnt==CNT_10ms-1) ? 1'b1 : 1'b0 ;
		
endmodule




module	control
(
	input		wire			clk			,
	input		wire			rst_n		,
	input		wire	[1:0]	sw			,
	input		wire			left		,
	input		wire			right		,
	input		wire	[31:0]	result		,
	input		wire	[31:0]	pc			,
	output	reg	[7:0]	display	,
	output	reg	[3:0]	leds		
);

reg	[1:0]	cnt_byte;
reg	[31:0]	data;

always@(*)
	case(sw)
		2'b10		:	data = result;
		2'b01		:	data = pc;
		default	:	data = 0;
	endcase

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt_byte<=2'd0;
	else if(left)
		cnt_byte<=cnt_byte+2'd1;
	else if(right)
		cnt_byte<=cnt_byte-2'd1;
		
always@(*)
	case(cnt_byte)
		2'd0	:	display = data[7:0];
		2'd1	:	display = data[15:8];
		2'd2	:	display = data[23:16];
		2'd3	:	display = data[31:24];
	endcase
	
always@(*)
	case(cnt_byte)
		2'd0	:	leds = 4'b0001;
            2'd1	:	leds = 4'b0010;
            2'd2	:	leds = 4'b0100;
            2'd3	:	leds = 4'b1000;
	endcase
	
endmodule




module	segment
#(
	parameter	CNT_1ms	=	50_000
)
(
	input		wire			clk			,
	input		wire			rst_n		,
	input		wire	[7:0]	display	,
	output	reg	[1:0]	com		,
	output	reg	[7:0]	segs		
);
reg [ 7:0 ] COM_cnt = 'b0 ;
reg	[31:0]	cnt;
reg			sel;
reg	[3:0]	data;

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt<=0;
	else if(cnt<CNT_1ms-1)
		cnt<=cnt+1;
	else
		cnt<=0;
		
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		sel<=1'd0;
	else if(cnt==CNT_1ms-1)
		sel<=sel+1'd1;	
	else
		sel<=sel;
always@(posedge clk )
    COM_cnt <= COM_cnt + 1;		
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		com<=8'b1111_1111;
	else
		case({sel,COM_cnt})
            9'b000000000    :    com <= 2'b10;
            9'b110000000    :    com <= 2'b01;
		endcase
		
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		data<=4'h0;
	else
		case(sel)
			1'b0	:	data<=display[3:0];
			1'b1	:	data<=display[7:4];
		endcase

always@(*)
	begin
		case(data)
			4'b0000	:	segs[7:1] = 7'b1111110;			//0
			4'b0001	:	segs[7:1] = 7'b0110000;			//1
			4'b0010	:	segs[7:1] = 7'b1101101;			//2
			4'b0011	:	segs[7:1] = 7'b1111001;			//3
			4'b0100	:	segs[7:1] = 7'b0110011;			//4
			4'b0101	:	segs[7:1] = 7'b1011011;			//5
			4'b0110	:	segs[7:1] = 7'b1011111;			//6
			4'b0111	:	segs[7:1] = 7'b1110000;			//7
			4'b1000	:	segs[7:1] = 7'b1111111;			//8
			4'b1001	:	segs[7:1] = 7'b1111011;			//9
			4'b1010	:	segs[7:1] = 7'b1110111;			//r
			4'b1011	:	segs[7:1] = 7'b0011111;			//b
			4'b1100	:	segs[7:1] = 7'b1001110;			//C
			4'b1101	:	segs[7:1] = 7'b0111101;			//d
			4'b1110	:	segs[7:1] = 7'b1001111;			//E
			4'b1111	:	segs[7:1] = 7'b1000111;			//F
		endcase
	end
	
endmodule	

