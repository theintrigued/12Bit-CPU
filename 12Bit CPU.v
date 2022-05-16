`
module fulladd(input logic a,b,c, output logic s,cout);
assign s = a^b^c;
assign cout = (c & (a^b)) | (a&b);
endmodule

module clock_divider( input clk,
                      output logic clk_div);
    localparam constantNumber = 50000000;
    logic [31:0] count;
     
    always @ (posedge(clk))
    begin
        if (count == constantNumber - 1)
            count <= 32'b0;
        else
            count <= count + 1;
    end
    
    always @ (posedge(clk))
    begin
        if (count == constantNumber - 1)
            clk_div <= ~clk_div;
        else
            clk_div <= clk_div;
    end
endmodule



module shiftReg (CLK, clr, shift, load, Din, SI, Dout);
input CLK;
input clr; // clear register
input shift; // shift
input load; // load register from Din
input [7:0] Din; // Data input for load
input SI; // Input bit to shift in
output [7:0] Dout;
reg [7:0] Dout;
always @(posedge CLK) begin
if (clr) Dout <= 0;
else if (load) Dout <= Din;
else if (shift) Dout <= { Dout[6:0], SI };
end
endmodule 



module eightbitadder(reset,clk,shiftsignal,loadsignal,a, b, out, cout);
input reset,clk,shiftsignal,loadsignal;
input [7:0] a;
input [7:0] b;
output reg [7:0]out;
logic[7:0] tempout;
output cout;

wire[6:0] c;
parameter STEMP = 4'b1010, S11 = 4'b1111, S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101,  S6 = 3'b110 , S7 = 3'b111;
reg [8:0] present,next;
wire clocky;
clock_divider clock1(clk,clocky);

fulladd a1(a[0],b[0],0,tempout[0],c[0]);
fulladd a2(a[1],b[1],c[0],tempout[1],c[1]);
fulladd a3(a[2],b[2],c[1],tempout[2],c[2]);
fulladd a4(a[3],b[3],c[2],tempout[3],c[3]);
fulladd a5(a[4],b[4],c[3],tempout[4],c[4]);
fulladd a6(a[5],b[5],c[4],tempout[5],c[5]);
fulladd a7(a[6],b[6],c[5],tempout[6],c[6]);
fulladd a8(a[7],b[7],c[6],tempout[7],cout);




always@(posedge clocky)//present state logic
    begin
       if(reset) 
        present <= S11;
       else
       present <= next; 
    end
    
 always@(present,shiftsignal,loadsignal) //next state logic
    begin
    next = S11; // default state
    case(present)  
    S11: begin if (reset) next <= S11;
        else if (loadsignal) next <= STEMP; 
         else next <= S11;
         end
    STEMP:begin if (reset) next <= S11;
         else if (loadsignal) next <= S0; 
         else next <= STEMP;
         end
    S0: begin if (reset) next <= S11;
        else if (shiftsignal) next <= S1; 
         else next <= S0;
         end
    S1: begin if (reset) next <= S11;
        else if (shiftsignal) next<=S2; 
         else next<=S1;
         end
    S2: begin if (reset) next <= S11;
        else if (shiftsignal) next<=S3; 
         else next<=S2;
         end
    S3: begin if (reset) next <= S11;
        else if (shiftsignal) next<=S4; 
         else next<=S3;
         end
    S4: begin if (reset) next <= S11;
        else if  (shiftsignal) next<=S5; 
         else next<=S4;
         end
    S5: begin if (reset) next <= S11;
        else if  (shiftsignal) next<=S6; 
         else next<=S5;
         end
    S6: begin if (reset) next <= S11;
        else if (shiftsignal) next<=S7; 
         else next<=S6;
         end
    S7: begin next<=S7; 
         end
    endcase
    end
    
always@(clk) //output logic
    begin
    case(present)
S11:begin 
    out[0] <= 0;
    out[1] <= 0;
    out[2] <= 0;
    out[3] <= 0;
    out[4] <= 0;
    out[5] <= 0;
    out[6] <= 0;
    out[7] <= 0;
    end
S0:begin 
    out[7] <= tempout[0];
    end
S1:begin 
    out[7] <= tempout[1];
    out[6] <= tempout[0];
    end
S2:begin 
    out[7] <= tempout[2];
    out[6] <= tempout[1];
    out[5] <= tempout[0];
    end
S3:begin 
    out[7] <= tempout[3];
    out[6] <= tempout[2];
    out[5] <= tempout[1];
    out[4] <= tempout[0];
    end
S4:begin 
    out[7] <= tempout[4];
    out[6] <= tempout[3];
    out[5] <= tempout[2];
    out[4] <= tempout[1];
    out[3] <= tempout[0];
    end
S5:begin 
    out[7] <= tempout[5];
    out[6] <= tempout[4];
    out[5] <= tempout[3];
    out[4] <= tempout[2];
    out[3] <= tempout[1];
    out[2] <= tempout[0];
    end
S6:begin 
    out[7] <= tempout[6];
    out[6] <= tempout[5];
    out[5] <= tempout[4];
    out[4] <= tempout[3];
    out[3] <= tempout[2];
    out[2] <= tempout[1];
    out[1] <= tempout[0];
    end
S7:begin 
    out[7] <= tempout[7];
    out[6] <= tempout[6];
    out[5] <= tempout[5];
    out[4] <= tempout[4];
    out[3] <= tempout[3];
    out[2] <= tempout[2];
    out[1] <= tempout[1];
    out[0] <= tempout[0];
    end
    endcase
end
    
    

endmodule
  --------------------------------------------------------------------------




# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Switches
set_property PACKAGE_PIN V17 [get_ports {a[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[0]}]
set_property PACKAGE_PIN V16 [get_ports {a[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[1]}]
set_property PACKAGE_PIN W16 [get_ports {a[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[2]}]
set_property PACKAGE_PIN W17 [get_ports {a[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[3]}]
set_property PACKAGE_PIN W15 [get_ports {a[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[4]}]
set_property PACKAGE_PIN V15 [get_ports {a[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[5]}]
set_property PACKAGE_PIN W14 [get_ports {a[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[6]}]
set_property PACKAGE_PIN W13 [get_ports {a[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {a[7]}]
set_property PACKAGE_PIN V2 [get_ports {b[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[0]}]
set_property PACKAGE_PIN T3 [get_ports {b[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[1]}]
set_property PACKAGE_PIN T2 [get_ports {b[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[2]}]
set_property PACKAGE_PIN R3 [get_ports {b[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[3]}]
set_property PACKAGE_PIN W2 [get_ports {b[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[4]}]
set_property PACKAGE_PIN U1 [get_ports {b[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[5]}]
set_property PACKAGE_PIN T1 [get_ports {b[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[6]}]
set_property PACKAGE_PIN R2 [get_ports {b[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {b[7]}]	


##Buttons
set_property PACKAGE_PIN U18 [get_ports shiftsignal]						
	set_property IOSTANDARD LVCMOS33 [get_ports shiftsignal]
set_property PACKAGE_PIN W19 [get_ports reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN T17 [get_ports loadsignal]						
	set_property IOSTANDARD LVCMOS33 [get_ports loadsignal]



# LEDs
set_property PACKAGE_PIN U16 [get_ports {out[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[0]}]
set_property PACKAGE_PIN E19 [get_ports {out[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[1]}]
set_property PACKAGE_PIN U19 [get_ports {out[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[2]}]
set_property PACKAGE_PIN V19 [get_ports {out[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[3]}]
set_property PACKAGE_PIN W18 [get_ports {out[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[4]}]
set_property PACKAGE_PIN U15 [get_ports {out[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[5]}]
set_property PACKAGE_PIN U14 [get_ports {out[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[6]}]
set_property PACKAGE_PIN V14 [get_ports {out[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {out[7]}]
set_property PACKAGE_PIN V3 [get_ports {cout}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cout}]


