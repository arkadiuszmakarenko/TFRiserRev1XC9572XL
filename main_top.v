
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
	 output INTSIG6,
	 input INTSIG7,
	 input INTSIG8, //SPI_NSS



    // SPI COMMS 

    input SPI_CK, 
    input SPI_MOSI, 
    output SPI_MISO

);

wire rtc_decode = A[23:16] == 8'b1101_1100; //RTC registers at $DC0000 - $DCFFFF read,
reg rtc_int;
reg dsack_int;

always @(posedge CLKCPU_A) begin 
	rtc_int <= PUNT_IN & rtc_decode ;

end



// punt works by respecting the accelerator punt over our punt.
assign PUNT_OUT = PUNT_IN ? (rtc_decode ? 1'b0 : 1'bz) : 1'b0;
assign INTSIG2 = rtc_int;    

assign DSACK = rtc_int?(INTSIG7?2'b10:2'b11):2'bzz ;

assign INTSIG3 = A[3];
assign INTSIG5 = A[5];

endmodule