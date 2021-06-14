`include "very_simple_cpu.v"

parameter ADD=2'b00, AND=2'b01, JMP=2'b10, INC=2'b11;

module testbench;
  reg clk;
  reg resetn; 
  always begin
    clk = 0;
    #10;
    clk = 1;
    #10;
  end
  
  initial begin
    $fsdbDumpfile("cpu.fsdb");
    $fsdbDumpvars();
    resetn=0;
    if(~resetn)
    begin
      cpu.memory1.mem[0]   = {INC,6'b100000};
      cpu.memory1.mem[1]   = {ADD,6'b100001};
      cpu.memory1.mem[2]   = {ADD,6'b100010};
      cpu.memory1.mem[3]   = {INC,6'b100011};
      cpu.memory1.mem[4]   = {INC,6'b100011};
      cpu.memory1.mem[5]   = {JMP,6'b000111};
      cpu.memory1.mem[6]   = {ADD,6'b100100};
      cpu.memory1.mem[7]   = {ADD,6'b100101};
      cpu.memory1.mem[8]   = {ADD,6'b100110};
      cpu.memory1.mem[9]   = {AND,6'b100111};
      cpu.memory1.mem[10]   ={ADD,6'b101000};
      cpu.memory1.mem[11]   ={ADD,6'b101001};
      cpu.memory1.mem[12]   ={ADD,6'b101010};
      cpu.memory1.mem[32]   = 4'b0101;
      cpu.memory1.mem[33]   = 4'b1001;
      cpu.memory1.mem[34]   = 4'b1000;
      cpu.memory1.mem[35]   = 4'b1010;
      cpu.memory1.mem[36]   = 5'b10000;
      cpu.memory1.mem[37]   = 4'b0010;
      cpu.memory1.mem[38]   = 4'b0010;
      cpu.memory1.mem[39]   = 4'b0010;
      cpu.memory1.mem[40]   = 4'b0110;
      cpu.memory1.mem[41]   = 4'b0110;
      cpu.memory1.mem[42]   = 4'b0110;
      //cpu.register1.pc_reg=cpu.memory1.mem[0];
    end
    #30 resetn=1;
    #1100 $finish;
  end

  top cpu(.clk(clk),
          .resetn(resetn));
endmodule
