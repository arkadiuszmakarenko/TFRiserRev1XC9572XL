
`timescale 1ns / 1ps
/*
    Copyright (C) 2020, Stephen J. Leary
    All rights reserved.
    
    This file is part of CD32 USB Riser

    CD32 USB Riser is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.     
    
    You should have received a copy of the GNU General Public License
    along with CD32 USB Riser. If not, see <http://www.gnu.org/licenses/>.
*/





module main_top(

    input CLKCPU_A, 
    input AS20, 
    input DS20, 
    input RW, 
    input [23:0] A,
    
    inout [31:24] D,
    output [1:0] DSACK,

    // Punting... 
    input PUNT_IN, 
    output PUNT_OUT,
	 
	 //
	 output INTSIG1,
	 output INTSIG2,
	 output INTSIG3,
	 output INTSIG4,
	 output INTSIG5,
	 input INTSIG6,
	 input INTSIG7,
	 output INTSIG8, //SPI_NSS



    // SPI COMMS 

    input SPI_CK, 
    input SPI_MOSI, 
    output SPI_MISO

);

wire rtc_decode = A[23:8] == 16'b1101_1100_0000_0000; //RTC registers at $DC0000 - $DCFFFF read,
wire JOYDATA = A[23:3] == {20'hDFF00, 1'b1}; 

wire POTGOR_decode = A[23:1] == {20'hDFF01, 3'b011}; // POTGOR DFF016 
wire POTGO_decode = A[23:1] == {20'hDFF03, 3'b010};  // POTGO DFF034

wire CIAAPRA_decode = A[23:1] == {20'hBFE00,3'b000}; // CIAAPRA BFE001    

//wire POTGOR_decode = A[23:3] == {20'hDFF01, 1'b0}; // POTGOR DFF016 //DFF012 DFF014

wire enable = INTSIG6 == 1'b1;


wire punt_int = rtc_decode |( (JOYDATA|POTGOR_decode|POTGO_decode|CIAAPRA_decode)&enable );

reg rtc_int;
reg joy_int;
reg button_int;

reg[1:0] intsig_int;
reg punt_ok;

reg[1:0] ack;
reg actual_acknowledge = 0;



always @(posedge CLKCPU_A) begin 

	punt_ok <= PUNT_IN & punt_int;
		
	
	if (AS20 == 1'b0) begin
		rtc_int <= PUNT_IN & rtc_decode;
		joy_int <= PUNT_IN & JOYDATA;
		button_int <= PUNT_IN & (POTGOR_decode|POTGO_decode|CIAAPRA_decode);
	end else begin 
		rtc_int <= 1'b0;
		joy_int <= 1'b0;
		button_int <= 1'b0;
		end
	
	
	
	actual_acknowledge <= ack == 2'b01;  
   ack <= {ack[0], INTSIG7};
  
end



always @(posedge CLKCPU_A or posedge AS20) begin 
	if (AS20 == 1'b1) begin 
		intsig_int <= 2'b11;
	end else begin 
			if ( actual_acknowledge ) begin
				intsig_int <= 2'b10;
			end else begin
				intsig_int <= 2'b11; 
			end	
	end
end 




// punt works by respecting the accelerator punt over our punt.
assign PUNT_OUT = PUNT_IN ? ( punt_int ? 1'b0 : 1'bz) : 1'b0;

assign INTSIG2 = button_int&enable;
assign INTSIG1 = rtc_int;
assign INTSIG8 = joy_int&enable;   


assign DSACK = punt_ok?intsig_int:2'bzz ;
 

assign INTSIG3 = A[3];
assign INTSIG5 = A[5];

endmodule