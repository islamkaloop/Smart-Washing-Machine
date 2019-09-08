
module segment(c,out);
	input [3:0]c;
	output [6:0] out;
	reg [6:0] out;

	always @(c)begin
		case(c)
			4'b0000:out<=7'b1000000;
			4'b0001:out<=7'b1111001;
			4'b0010:out<=7'b0100100;
			4'b0011:out<=7'b0110000;
			4'b0100:out<=7'b0011001;
			4'b0101:out<=7'b0010010;
			4'b0110:out<=7'b0000010;
			4'b0111:out<=7'b1111000;
			4'b1000:out<=7'b0000000;
			4'b1001:out<=7'b0010000;
			default:out<=7'b1111111;
		endcase
	end
endmodule

module counter(out1,out2,clk,O);

	output [6:0] out1;
	output [6:0] out2;
	input clk,O;
	
	reg [6:0]out1;
	reg [6:0]out2;
	reg [3:0] c1;
	reg [3:0] c2;
	reg clk1;
	reg[30:0] wai;
	
	initial begin
	c1=4'b0000;
	c2=4'b0000;
	clk1=1'b0;
	wai=0;	
	end
	
	always @(posedge clk) begin 
		wai<=wai+1;
		if(wai==25000000)begin
			clk1 <= ~clk1;
			wai<=0;
		end
	end
	
	always @(posedge clk1 or negedge O) begin
		if(O==1'b0)begin
			c1<=4'b0000;
			c2<=4'b0000;
		end
		else begin
			if(c1==4'b1001)begin
				if(c2==4'b1001)begin
					c1=4'b0000;
					c2=4'b0000;
				end
				else begin
					c1=4'b0000;
					c2=c2+1'b1;
				end
			end
			else
				c1=c1+1'b1;
		end
	end
		
	wire [6:0] out3,out4;

	segment(c1,out3);
	segment(c2,out4);
		
	always @(out3 or out4)begin
		out1<=out3;
		out2<=out4;
	end
endmodule

module senstreg(sens,clk,c,O);
	output [6:0] c;
	input sens,O,clk;
	reg [6:0] c;
	reg [3:0] c1;
	reg [30:0]wai=0;
	reg s=1'b1;
	initial begin
		c1=4'b0000;
	end
	
	always @(negedge clk or negedge O) begin
		if(O==1'b0)begin
			c1<=4'b0000;
		end
		else begin
				if(s==1'b1 & sens==1'b0)begin
					c1=c1+1'b1;
					s<=1'b0;
				end
				if(s==1'b0)begin
					wai<=wai+1;
					if(wai==25000000)begin
						s<=1'b1;
						wai<=0;
					end
				end
		end
	end
	wire [6:0] c2;
	segment(c1,c2);
	always @(c2)
		c<=c2;	
endmodule 

module main(clk,start,sens,state,buz,c1,c2,M1,B1,B2);
	output [6:0] c1;
	output [6:0] c2;
	output [3:0] state;
	output buz,M1,B1,B2;
	input clk,start,sens;
	reg [6:0] c1;
	reg [6:0] c2;
	reg [3:0] state=3'b0000;
	reg buz;
	reg O1;
	reg O2;
	reg O3;
	reg O4;
	reg M1=1'b0;
	reg B1=1'b0;
	reg B2=1'b1;
	reg bu=1'b0;
	reg st=1'b0;
	reg[60:0] wai=0;
	reg i=1'b0;
	
	initial begin
		c1=7'b1000000;
		c2=7'b1000000;
		buz=1'b0;
		O1<=1'b0;
		O2<=1'b0;
		O3<=1'b0;
		O4<=1'b0;
	end
		
	wire [6:0] c3,c4,c5,c6,c7,c8,c9;
	senstreg (sens,clk,c3,O1);
	counter (c4,c5,clk,O2);
	counter (c6,c7,clk,O3);
	counter (c8,c9,clk,O4);
	
	always@(posedge start or posedge i)begin
		if(i)
			st<=1'b0;
		else begin
			if(st ==1'b0)
				st<=1'b1;
		end
		
	end

	always @(negedge clk)begin
		if(st ==1'b1)begin
			if(state == 4'b0000)begin
				state <= 4'b0001;
				O1<=1'b1;
				O2<=1'b0;
				O3<=1'b0;
				O4<=1'b0;
				i<=1'b0;
			end
			if(state == 4'b0001)begin 
				if(c1==7'b0011001)begin
					state <= 4'b0010;
					O1<=1'b0;
					O2<=1'b1;
					O3<=1'b0;
					O4<=1'b0;
					c1<=7'b1000000;
					c2<=7'b1000000;
				end
				else begin
					c1<=c3;
				end
			end
			if(state == 4'b0010)begin 
				
				if(c1==7'b0011001)begin
					state <= 4'b0100;
					O1<=1'b0;
					O2<=1'b0;
					O3<=1'b1;
					O4<=1'b0;
					c1<=7'b1000000;
					B1<=1'b0;
				end
				else begin
					c1<=c4;
					B1<=1'b1;
				end
			end
			if(state == 4'b0100)begin 
				if(c1==7'b1000000 & c2==7'b0100100)begin
					state <= 4'b1000;
					O1<=1'b0;
					O2<=1'b0;
					O3<=1'b0;
					O4<=1'b1;
					c1<=7'b1000000;
					c2<=7'b1000000;
					M1<=1'b0;
				end
				else begin
					c1<=c6;
					c2<=c7;
					M1<=1'b1;
				end
			end
			if(state == 4'b1000)begin 
				if(c1==7'b0010010 & c2==7'b1111001)begin
					state <= 4'b0000;
					O1<=1'b0;
					O2<=1'b0;
					O3<=1'b0;
					O4<=1'b0;
					i<=1'b1;
					c1<=7'b1000000;
					c2<=7'b1000000;
					B2<=1'b1;
				end
				else begin
					c1<=c8;
					c2<=c9;
					B2<=1'b0;
				end
			end
		end
		else 
			i<=1'b0;
	end
	
	always @(posedge clk or posedge i)begin
		if(i)
			bu<=1'b1;
		else begin
			if(bu==1'b1)begin
				buz<=1'b1;
				wai<=wai+1;
				if(wai==100000000)begin
					buz <= 1'b0;
					wai<=0;
					bu<=1'b0;
				end
			end
		end
	end
	
endmodule 


	
	

	