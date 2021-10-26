module ahb_master (input hclk,input hresetn,input[1:0] hresp,input[31:0] hrdata, input hreadyout,output reg hwrite, output reg hreadyin, output reg[1:0]htrans,output reg[31:0] hwdata, output reg[31:0]haddr);



task single_read();
begin
@(posedge hclk)
begin
#1;
hwdata=32'hzzzzzzzz;
haddr = 32'h8000FFFF;
hwrite = 0;
hreadyin = 1;
htrans = 2'b10;
end

@(posedge hclk)
begin
#1;
hreadyin = 0;
htrans = 2'b00;
end
end
endtask

task single_write();
begin
@(posedge hclk)
begin
#1;
haddr=32'h80000011;

hwrite = 1;
hreadyin = 1;
htrans = 2'b10;

end

@(posedge hclk)
begin
#1;
htrans = 2'b00;
hwdata = 32'h80000CCC;
//hreadyin =1;
end
end
endtask
endmodule