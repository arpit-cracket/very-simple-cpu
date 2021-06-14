# very-simple-cpu

This is an implementation of a very simple CPU, comprising of 4 operations- JMP, AND, ADD, INC
I tried to implement the very simple CPU implementation from Carpinelli's Computer System Organization book.
It is accompanied by a plain testbench, which does backdoor write to memory for initial instruction. Out of 100 current testbench infra is at 1, which present lots of scope of testbench improvement

Potential problem in FETCH3 stage - 
During implementation of verilog code, I realized that IR assignment happens during FETCH3 stage to IR register.
And also in very next cycle the control unit requires IR value to be picked for deciding the next stage out of ADD/AND/JMP/INC.
This will fail as it will pick the previous value of IR register.

Possible Solutions-
1st - Make the IR load on FETCH2 itself. Since the previous data on bus was also instruction+address, this will work.
2nd - Instead of assigning output IR to control logic, directly pass the bus[7:6] to control logic. Since control logic only uses it in FETCH3 stage so there is proper control.

P.S. Feel free to connect with me to discuss issues in the implmentation/suggestions on code improvement.
arpitjaiswal522@yahoo.com
