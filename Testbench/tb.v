module top_tb();

reg hclk,hresetn;

wire hreadyout;
wire penableout,pwriteout;
wire [2:0]pselxout;
wire [31:0] paddrout,pwdataout;
wire [31:0]prdata;

wire hwrite,hreadyin;
wire [1:0]htrans;
wire [31:0]hwdata,haddr;
wire [1:0]hresp;
wire [31:0]paddr,pwdata,hrdata;
wire penable,pwrite;
wire [2:0]pselx;

ahb_master ahb(.hclk(hclk),.hresetn(hresetn),.hresp(hresp),.hrdata(hrdata),.hreadyout(hreadyout), .hwrite(hwrite),.hreadyin(hreadyin), .htrans(htrans),.hwdata(hwdata),.haddr(haddr));

bridge u1(.hclk(hclk),.hresetn(hresetn),.penable(penable),.pwrite(pwrite),.pselx(pselx),.paddr(paddr),.pwdata(pwdata),.hreadyout(hreadyout),.hwrite(hwrite),.hreadyin(hreadyin),.hwdata(hwdata),.haddr(haddr),.htrans(htrans),.prdata(prdata),.hrdata(hrdata),.hresp(hresp));

apb_interface apb(.penable(penable),.pwrite(pwrite),.pselx(pselx),.paddr(paddr),.pwdata(pwdata),.penableout(penableout),.pwriteout(pwriteout), .pselxout(pselxout),.paddrout(paddrout),.pwdataout(pwdataout),.prdata(prdata));

initial
begin
hclk=0;
forever #10 hclk=~hclk;
end

task rst();
begin
@(posedge hclk);
hresetn = 1;
@(posedge hclk);
hresetn = 0;
end
endtask

initial
begin
rst;
ahb.single_write;
#100;

ahb.single_read;

end

initial
#400 $finish;

endmodule