module apb_controller(input hclk,input hresetn,input valid,input hwrite,input hwrite_reg,input[31:0]haddr_1,input[31:0]haddr_2,input[31:0]hwdata_1,input[31:0]hwdata_2,input[2:0]temp_selx,output reg pwrite,output reg penable,output reg [2:0]pselx,output reg [31:0]paddr,output reg [31:0]pwdata,output reg hreadyout);
  
  parameter idle=0,read=1,wwait=2,write=3,writep=4,renable=5,wenable=6,wenablep=7;
  
  reg[2:0]PS,NS;
  
  always@(posedge hclk)
    begin
      if(hresetn)
		 
          PS<=idle;
          pselx<=3'bzzz;
          penable<=1'bz;
          paddr<=32'hzzzzzzzz;
          pwdata<=32'hzzzzzzzz;
			
      else
          PS<=NS;
    end
  
  always@(*)
	 begin
      case(PS)
        idle: begin 
              pselx=3'd0;
              penable=0;
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
        end
        
         read:begin
           paddr=haddr_2;
           pselx=temp_selx;
           pwrite=0;
           NS=renable;
         end
           
        
        wwait:NS=valid?writep:write;
        
        write: begin 
               paddr=haddr_2;
               pselx=temp_selx;
               pwrite=1;
               pwdata=hwdata_2;
               
           NS=valid?wenablep:wenable;
        end
        
        writep: begin 
               paddr=haddr_2;
               pselx=temp_selx;
               pwrite=1;
               pwdata=hwdata_2;
               
               NS=wenablep;
        end
        
        renable:begin
          penable=1;
          hreadyout=1;
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
        end
        
        wenable:begin
          penable=1;
          hreadyout=1;
          if(!valid)NS=idle;else NS=(valid & hwrite)?wwait:read;
        end
        
        wenablep:begin
          penable=1;
          hreadyout=1;
          if(!hwrite_reg)NS=read;else NS=(valid & hwrite_reg)?writep:write;
        end
        
        
      endcase
		
    end
endmodule
