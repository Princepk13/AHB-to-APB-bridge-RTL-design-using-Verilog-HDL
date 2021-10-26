module ahb(input hclk,input hresetn,input hwrite,input hreadyin,input[31:0]hwdata,input[31:0]haddr,input[1:0]htrans,output reg  valid,output reg[31:0]haddr_1,output reg[31:0]haddr_2,output reg[31:0]hwdata_1,output reg[31:0]hwdata_2,output reg hwrite_reg,output reg[2:0] temp_selx);
  
  parameter idle=2'b00,
            busy=2'b01,
            non_seq=2'b10,
            seq=2'b11;
  
  reg[31:0] q1;
  reg[31:0] q2;
  reg q3,q4;
  
 always@(posedge hclk or negedge hresetn)
    begin
      if(hresetn)
        begin
          q1<=32'hzzzzzzzz;
          haddr_1=32'hzzzzzzzz;
          haddr_2=32'hzzzzzzzz;
          q2<=32'hzzzzzzzz;
          hwdata_1=32'hzzzzzzzz;
          hwdata_2=32'hzzzzzzzz;
          q3<=1'bz;
          q4<=1'bz;
          hwrite_reg<=1'bz;
          
         
        end
      else 
        begin
          q1<=haddr;
          haddr_1<=q1;
          haddr_2<=haddr_1;


          q2<=hwdata;
          hwdata_1<=q2;
          hwdata_2<=hwdata_1;

          q3<=hwrite;
          q4<=q3;
          hwrite_reg<=q4;
         
        end
    end

  

 
  
  always@(*)
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
	 
  always@(*)
    begin
      if(hresetn)
        begin
          temp_selx=3'bzzz;
        end
      else 
        begin
          if(haddr>=32'h80000000 && haddr<32'h84000000) temp_selx=3'd1;
          if(haddr>=32'h84000000 && haddr<32'h88000000) temp_selx=3'd2;
          if(haddr>=32'h88000000 && haddr<32'h8C000000) temp_selx=3'd4;
        end
    end
          
	 endmodule


module apb_controller(input hclk,input hresetn,input valid,input hwrite,input hwrite_reg,input[31:0]haddr_1,input[31:0]haddr_2,input[31:0]hwdata_1,input[31:0]hwdata_2,input[2:0]temp_selx,output reg pwrite,output reg penable,output reg [2:0]pselx,output reg [31:0]paddr,output reg [31:0]pwdata,output reg hreadyout,output reg[2:0] state);
  
  parameter idle=0,read=1,wwait=2,write=3,writep=4,renable=5,wenable=6,wenablep=7;
  
  reg[2:0]PS,NS;
  reg[1:0]count;
  
  always@(posedge hclk)
    begin
      if(hresetn)
	begin	 
          PS<=idle;
        
	 end		
			
      else
          PS<=NS;
    end
  
  always@(*)
	 begin
	 
      case(PS)
        idle: 
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
      
        
         read:if(count==2'b10)NS=renable;
         
           
        
        wwait: if(count==2'b10)NS=valid?writep:write;
                
            
        
        write: 
               
           NS=valid?wenablep:wenable;
        
        
        writep: 
               
               NS=wenablep;
       
        
        renable:
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
        
        
        wenable:
         
         
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
        
        
        wenablep:
       
          if(!hwrite_reg)NS=read;else NS=(valid & hwrite_reg)?writep:write;
       
        
        
      endcase
		
    end

  
  always@(posedge hclk)
  begin
   if(hresetn)
	 begin
       pselx<=3'bzzz;
       penable<=1'bz;
       paddr<=32'hzzzzzzzz;
       pwdata<=32'hzzzzzzzz;
       pwrite<=1'bz;
       count<=2'b00;
		 end
	else
     assign state=PS;
      begin
       if(PS==3'b000)begin pselx<=3'd0;penable<=0;pwrite<=pwrite;end
       if(PS==3'b001)begin if(count==2'b10)begin pselx<=temp_selx;pwrite<=0;pwdata<=hwdata_2;paddr<=haddr_2; end count<=count+1;end 
       if(PS==3'b010)count<=count+1;
       if(PS==3'b011)begin pselx<=temp_selx;pwrite<=1;pwdata<=hwdata_2;paddr=haddr_2;count<=0;end
       if(PS==3'b100)begin paddr<=haddr_2;pselx<=temp_selx;pwrite<=1;pwdata<=hwdata_2;end
       if(PS==3'b101)begin penable<=1;hreadyout<=1;end
       if(PS==3'b110)begin penable<=1;hreadyout<=1;end
       if(PS==3'b111)begin penable<=1;hreadyout<=1;end
    end
	 end

endmodule



module bridge(input hclk,input hresetn,input hwrite,input hreadyin,input [1:0]htrans,input[31:0]haddr,input[31:0]hwdata,input[31:0]prdata,output[31:0]hrdata,output pwrite,output  penable,output  [2:0]pselx,output  [31:0]paddr,output  [31:0]pwdata,output hreadyout,output[1:0]hresp,output[2:0]state);
wire  valid;wire [31:0]haddr_1;wire [31:0]haddr_2;wire[31:0]hwdata_1;wire[31:0]hwdata_2;wire hwrite_reg;wire[2:0] temp_selx;
assign hrdata=prdata;
assign hresp=2'b00;
ahb u1(.hclk(hclk),.hresetn(hresetn),.hwrite(hwrite),.hreadyin(hreadyin),.htrans(htrans),.haddr(haddr),.hwdata(hwdata),.valid(valid),.haddr_1(haddr_1),.haddr_2(haddr_2),.hwdata_1(hwdata_1),.hwdata_2(hwdata_2),.hwrite_reg(hwrite_reg),.temp_selx(temp_selx));
apb_controller u2(.hclk(hclk),.hresetn(hresetn),.hwrite(hwrite),.valid(valid),.haddr_1(haddr_1),.haddr_2(haddr_2),.hwdata_1(hwdata_1),.hwdata_2(hwdata_2),.hwrite_reg(hwrite_reg),.temp_selx(temp_selx),.penable(penable),.pwrite(pwrite),.pselx(pselx),.paddr(paddr),.pwdata(pwdata),.hreadyout(hreadyout),.state(state));
endmodule	 