module apb_interface(input penable,input pwrite,input[31:0]pwdata,input[2:0]pselx,input[31:0]paddr,output reg penableout,output reg pwriteout,output reg [31:0] pwdataout,output reg[31:0] paddrout,output reg[2:0] pselxout,output reg[31:0]prdata);
 reg [31:0]data;
 
 always@(penable or pwrite or paddr)
  begin
  penableout<=penable;
  pwriteout<=pwrite;
  pwdataout<=pwdata;
  pselxout<=pselx;
  paddrout<=paddr;
   
   case({pwrite,penable})
   2'd1:prdata=data;
   2'd3:data=pwdata;
   default:prdata=32'hzzzzzzzz;
   endcase
  end
endmodule