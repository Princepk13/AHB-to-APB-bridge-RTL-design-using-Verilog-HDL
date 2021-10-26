module ahb(input hclk,input hresetn,input hwrite,input hreadyin,input[31:0]hwdata,input[31:0]haddr,input[1:0]htrans,output reg  valid,output reg[31:0]haddr_1,output reg[31:0]haddr_2,output reg[31:0]hwdata_1,output reg[31:0]hwdata_2,output reg hwrite_reg,output reg[2:0] temp_selx);
  
  parameter idle=2'b00,
            busy=2'b01,
            non_seq=2'b10,
            seq=2'b11;
  
  reg[31:0] q1;
  reg[31:0] q2;
  reg q3,q4;
  
  always@(posedge hclk)
    begin
      if(hresetn)
        begin
          q1<=0;
          q2<=0;
          q3<=0;
        end
      else 
        begin
          q1<=haddr;
          q2<=hwdata;
          q3<=hwrite;
        end
    end
  
  always@(posedge hclk)
    begin
      if(hresetn)
        begin
          haddr_1<=0;
          hwdata_1<=0;
          q4<=0;
        end
      else 
        begin
          haddr_1<=q1;
          hwdata_1<=q2;
          q4<=q3;
        end
    end
  
  always@(posedge hclk)
    begin
      if(hresetn)
        begin
          haddr_2<=0;
          hwdata_2<=0;
          hwrite_reg<=0;
        end
      else 
        begin
          haddr_2<=haddr_1;
          hwdata_2<=hwdata_1;
          hwrite_reg<=q4;
        end
    end
  
  always@(htrans)
    begin
      if(hresetn || !hreadyin)
        begin
          valid=0;
        end
      else if(hreadyin)
        begin
          
      case(htrans)
        idle:    valid=0;
        busy:    valid=0;
        non_seq: valid=1;
        seq:     valid=1;
        default: valid=1'b0;
      endcase
        end
    end
	 
  always@(haddr)
    begin
      if(hresetn)
        begin
          temp_selx=3'd0;
        end
      else 
        begin
          if(haddr>=32'h80000000 && haddr<32'h84000000) temp_selx=3'd1;
          if(haddr>=32'h84000000 && haddr<32'h88000000) temp_selx=3'd2;
          if(haddr>=32'h88000000 && haddr<32'h8C000000) temp_selx=3'd4;
        end
    end
          
	 endmodule
	 