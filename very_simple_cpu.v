parameter FETCH1 =0,FETCH2=1,FETCH3=3,ADD1=8,ADD2=9,AND1=10,AND2=11,JMP1=12,INC1=14;

module counter (input clk,
                input resetn,
                input ld,
                input inc,
                input clr,
                input [1:0] ir,
                output [3:0] count);
  reg [3:0] count_val;
  always @(posedge clk)
  begin
    if (~resetn)
      count_val <= 0;
    else if(clr)
      count_val <= 0;
    else if (ld)
      count_val <= {1'b1,ir,1'b0};
    else if (inc)
      count_val <= count_val+1;
    $strobe(" time: %0t, count_val: 0x%0h",$time,count_val);
  end
  assign count = count_val;
endmodule

module decoder (input [3:0] count,
                output [15:0] decoder_out
              );

  assign decoder_out[FETCH1]=(count==0)?1:0;
  assign decoder_out[FETCH2]=(count==1)?1:0;
  assign decoder_out[FETCH3]=(count==2)?1:0;
  assign decoder_out[ADD1]=(count==8)?1:0;
  assign decoder_out[ADD2]=(count==9)?1:0;
  assign decoder_out[AND1]=(count==10)?1:0;
  assign decoder_out[AND2]=(count==11)?1:0;
  assign decoder_out[JMP1]=(count==12)?1:0;
  assign decoder_out[INC1]=(count==14)?1:0;
endmodule

module control_logic (input [15:0] decoder_out,
                      output ld,
                      output inc,
                      output clr,
                      output pcload,
                      output pcinc,
                      output drload,
                      output acload,
                      output acinc,
                      output arload,
                      output irload,
                      output membus,
                      output pcbus,
                      output drbus,
                      output alusel,
                      output read
                    );
  
  assign ld = decoder_out[FETCH3]?1:0;
  assign inc = decoder_out[FETCH1]|decoder_out[FETCH2]|decoder_out[ADD1]|decoder_out[AND1]?1:0;
  assign clr = decoder_out[JMP1]|decoder_out[INC1]|decoder_out[ADD2]|decoder_out[AND2]?1:0;
  assign pcload = decoder_out[JMP1]?1:0;
  assign pcinc = decoder_out[FETCH2]?1:0;
  assign drload = decoder_out[FETCH2]|decoder_out[ADD1]|decoder_out[AND1]?1:0;
  assign acload = decoder_out[ADD2]|decoder_out[AND2]?1:0;
  assign acinc = decoder_out[INC1]?1:0;
  assign irload = decoder_out[FETCH3]?1:0;
  assign arload = decoder_out[FETCH1]|decoder_out[FETCH3]?1:0;
  assign membus = decoder_out[FETCH2]|decoder_out[ADD1]|decoder_out[AND1]?1:0;
  assign pcbus = decoder_out[FETCH1]?1:0;
  assign drbus = decoder_out[FETCH3]|decoder_out[ADD2]|decoder_out[AND2]|decoder_out[JMP1]?1:0;
  assign alusel = decoder_out[AND2]?1:0; //AND1 Instead of AND2? But again it's combinational logic TODO
  assign read = decoder_out[FETCH2]|decoder_out[ADD1]|decoder_out[AND1]?1:0;

endmodule

module control_unit(input clk,
                    input resetn,
                    input [1:0]ir,
                    output pcload,
                    output pcinc,
                    output drload,
                    output acload,
                    output acinc,
                    output irload,
                    output arload,
                    output membus,
                    output pcbus,
                    output drbus,
                    output alusel,
                    output read
                );

  wire [3:0]  count;
  wire [15:0] decoder_out;
  wire ld, inc, clr;
  counter counter1(.clk(clk),
                          .resetn(resetn),
                          .ld(ld),
                          .inc(inc),
                          .clr(clr),
                          .ir(ir),
                          .count(count));
 
  decoder decoder1(.count(count),
                          .decoder_out(decoder_out));

  control_logic control_logic1(.decoder_out(decoder_out),
                                      .ld(ld),
                                      .inc(inc),
                                      .clr(clr),
                                      .pcload(pcload),
                                      .pcinc(pcinc),
                                      .drload(drload),
                                      .acload(acload),
                                      .acinc(acinc),
                                      .irload(irload),
                                      .arload(arload),
                                      .membus(membus),
                                      .pcbus(pcbus),
                                      .drbus(drbus),
                                      .alusel(alusel),
                                      .read(read));

endmodule

module memory(input read,
              input clk,
              input resetn,
              input [5:0] a,
            inout [7:0] d);

  reg [7:0] mem [64];
  assign d = read? mem[a]:1'bz;
endmodule

module alu (input [7:0] ac_in,
            input [7:0] dr,
            input sel,
          output [7:0] ac_out);
  
    assign  ac_out = sel?(ac_in&dr):(ac_in+dr);

endmodule

module regsiter ( input clk,
                  input resetn,
                  inout [7:0]d,
                  input membus,
                  input arload,
                  input pcload,
                  input pcbus,
                  input drbus,
                  input pcinc,
                  input drload,
                  input acload,
                  input acinc,
                  input alusel,
                  input irload,
                  output [5:0]a,
                  output [1:0]ir
                );
  wire [7:0] bus,alu_out;
  reg [5:0] pc_reg,ar_reg;
  reg [7:0] dr_reg,ac_reg;
  reg [1:0] ir_reg;

  assign bus =  membus  ? d :
                pcbus   ? pc_reg:
                drbus   ? dr_reg: 1'bz;

  assign a = ar_reg;

  always @(posedge clk)
  begin
    if(~resetn) begin
        ar_reg <= 0;
        pc_reg <= 0;
        dr_reg <= 0;
        ac_reg <= 0;
        ir_reg <= 0;
    end
    else begin
      if(arload)
        ar_reg <= bus[5:0];
      
      if(pcload)
        pc_reg <= bus[5:0];
      else if(pcinc)
        pc_reg <= pc_reg+1;

      if(drload)
        dr_reg <= bus;

      if(acload)
        ac_reg <= alu_out;
      else if(acinc)
        ac_reg <= ac_reg+1;

      if(irload)
        ir_reg <= bus[7:6];
      end
      $strobe(" time: %0t, ac_reg: 0b%0b",$time,ac_reg);
    end
  
  assign ir = bus[7:6]; //Trying Bypassing of IR register, as post FETCH3 load signal of counter needs ir, so it serves both purposes of proper control and reaching in time

  alu alu1( .ac_in(ac_reg),
            .dr(bus),
            .sel(alusel),
            .ac_out(alu_out));

endmodule

module top(input clk,input resetn);
  
  wire pcload,pcinc,drload,acload,acinc,irload,membus,pcbus,drbus,read,alusel,arload;
  wire [1:0] ir;
  wire [5:0] a;
  wire [7:0] d;
  
  control_unit control_unit1(.clk(clk),
                            .resetn(resetn),
                            .ir(ir),
                            .pcload(pcload),
                            .pcinc(pcinc),
                            .drload(drload),
                            .arload(arload),
                            .acload(acload),
                            .acinc(acinc),
                            .irload(irload),
                            .membus(membus),
                            .pcbus(pcbus),
                            .drbus(drbus),
                            .alusel(alusel),
                            .read(read));

  memory memory1( .read(read),
                  .clk(clk),
                  .resetn(resetn),
                  .a(a),
                  .d(d));

  regsiter register1 (.clk(clk),
                      .resetn(resetn),
                      .d(d),
                      .membus(membus),
                      .arload(arload),
                      .pcload(pcload),
                      .pcbus(pcbus),
                      .drbus(drbus),
                      .pcinc(pcinc),
                      .drload(drload),
                      .acload(acload),
                      .acinc(acinc),
                      .alusel(alusel),
                      .irload(irload),
                      .ir(ir),
                      .a(a));

endmodule

