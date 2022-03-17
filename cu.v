module cu (
input [15:0] instr_fd,
// outputs to execute
output reg illegalop_cu,
output reg returnepc_cu,
output reg halt_dx,
output reg [2:0] setcondsel_dx,
output reg writedatasel_dx,
output reg [3:0] aluop_dx,
output reg cin_dx,
output reg inva_dx,
output reg memread_cu,
output reg memwrite_cu,
output reg [1:0] regsrcsel_dx,
output reg branch_cu,
output reg jump_cu,
output reg zeroextsel_cu,
output reg regwrite_cu,
output reg [1:0] alusrcsel_dx,
output reg immsrcsel_cu,
output reg immaddsel_cu,
output reg pcsel_dx,
output reg condsel_dx,
// error output
output reg err_cu
);

wire [4:0] opcode;
wire [1:0] func;

assign opcode = instr_fd[15:11];
assign func = instr_fd[1:0];

always @(*) begin
   // default output values
   illegalop_cu = 1'b0;
   returnepc_cu = 1'b0;
   halt_dx = 1'b0;
   memread_cu = 1'b0;
   memwrite_cu = 1'b0;   
   writedatasel_dx = 1'b0;
   regsrcsel_dx = 2'b00;
   aluop_dx = 4'b0000;
   alusrcsel_dx = 2'b00;
   cin_dx = 1'b0;
   inva_dx = 1'b0;
   condsel_dx = 1'b0;
   pcsel_dx = 1'b0;
   setcondsel_dx = 3'b000;
   branch_cu = 1'b0;
   jump_cu = 1'b0;
   immsrcsel_cu = 1'b0;
   immaddsel_cu = 1'b0;
   regwrite_cu = 1'b0;
   zeroextsel_cu = 1'b0;
   err_cu = 1'b0;
   case(opcode)
      // halt
      5'b00000 : begin
         halt_dx = 1'b1;
      end
      // nop
      5'b00001 : begin
      end
      // siic
      5'b00010 : begin
         illegalop_cu = 1'b1;
      end
      // nop/rti
      5'b00011 : begin
         returnepc_cu = 1'b1;
      end
      // addi
      5'b01000 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b11;
      end
      // subi
      5'b01001 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b11;
         inva_dx = 1'b1;
         cin_dx = 1'b1;
      end
      // xori
      5'b01010 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0110;
         alusrcsel_dx = 2'b11;
         zeroextsel_cu = 1'b1;
      end
      // andni
      5'b01011 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0111;
         alusrcsel_dx = 2'b11;
         zeroextsel_cu = 1'b1;
      end
      // roli
      5'b10100 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0000;
         alusrcsel_dx = 2'b11;
      end
      // slli
      5'b10101 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0001;
         alusrcsel_dx = 2'b11;
      end
      // rori
      5'b10110 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0010;
         alusrcsel_dx = 2'b11;
      end
      // srli
      5'b10111 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0011;
         alusrcsel_dx = 2'b11;
      end
      // st
      5'b10000 : begin
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b11;
         memwrite_cu = 1'b1;
      end
      // ld
      5'b10001 : begin
         regwrite_cu = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b11;
         memread_cu = 1'b1;
      end
      // stu
      5'b10011 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b11;
         memwrite_cu = 1'b1;
         regsrcsel_dx = 2'b01;
      end
      // btr
      5'b11001 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b1000;
         alusrcsel_dx = 2'b01;
         regsrcsel_dx = 2'b10;
       end
       // add, sub, xor, andn
       5'b11011 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = (func == 2'b00) ? 4'b0100 :
                    (func == 2'b01) ? 4'b0100 :
                    (func == 2'b10) ? 4'b0110 :
                    4'b0111;
         cin_dx = (func == 2'b01) ? 1'b1 : 1'b0;
         inva_dx = (func == 2'b01) ? 1'b1 : 1'b0;
         alusrcsel_dx = 2'b01;
         regsrcsel_dx = 2'b10;
      end
      // rol, sll, ror, srl
      5'b11010 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = (func == 2'b00) ? 4'b0000 :
                    (func == 2'b01) ? 4'b0001 :
                    (func == 2'b10) ? 4'b0010 :
                    4'b0011;
         alusrcsel_dx = 2'b01;
         regsrcsel_dx = 2'b10;
      end
      // seq
      5'b11100 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b01;
         cin_dx = 1'b1;
         inva_dx = 1'b1;
         setcondsel_dx = 3'b000;
         condsel_dx = 1'b1;
         regsrcsel_dx = 2'b10;
      end
      // slt
      5'b11101 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b01;
         cin_dx = 1'b1;
         inva_dx = 1'b1;
         setcondsel_dx = 3'b001;
         condsel_dx = 1'b1;
         regsrcsel_dx = 2'b10;
      end
      // sle
      5'b11110 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b01;
         cin_dx = 1'b1;
         inva_dx = 1'b1;
         setcondsel_dx = 3'b010;
         condsel_dx = 1'b1;
         regsrcsel_dx = 2'b10;
      end
      // sco
      5'b11111 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         aluop_dx = 4'b0100;
         alusrcsel_dx = 2'b01;
         setcondsel_dx = 3'b101;
         condsel_dx = 1'b1;
         regsrcsel_dx = 2'b10;
      end
      // beqz
      5'b01100 : begin
         setcondsel_dx = 3'b000;
         branch_cu = 1'b1;
         immsrcsel_cu = 1'b1;      
      end
      // bnez
      5'b01101 : begin
         setcondsel_dx = 3'b011;
         branch_cu = 1'b1;
         immsrcsel_cu = 1'b1;
      end
      // bltz
      5'b01110 : begin
         setcondsel_dx = 3'b001;
         branch_cu = 1'b1;
         immsrcsel_cu = 1'b1;
      end
      // bgez
      5'b01111 : begin
         setcondsel_dx = 3'b100;
         branch_cu = 1'b1;
         immsrcsel_cu = 1'b1;
      end
      // lbi
      5'b11000 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         alusrcsel_dx = 2'b00;
         aluop_dx = 4'b1011;
         regsrcsel_dx = 2'b01;
      end
      // slbi
      5'b10010 : begin
         regwrite_cu = 1'b1;
         zeroextsel_cu = 1'b1;
         writedatasel_dx = 1'b1;
         alusrcsel_dx = 2'b00;
         aluop_dx = 4'b1001;
         regsrcsel_dx = 2'b01;
      end
      // j
      5'b00100 : begin
         jump_cu = 1'b1;
      end
      // jal
      5'b00110 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         regsrcsel_dx = 2'b11;
         jump_cu = 1'b1;
         pcsel_dx = 1'b1;
      end
      // jr
      5'b00101 : begin
         jump_cu = 1'b1;
         immsrcsel_cu = 1'b1;
         immaddsel_cu = 1'b1;
      end
      // jalr
      5'b00111 : begin
         regwrite_cu = 1'b1;
         writedatasel_dx = 1'b1;
         jump_cu = 1'b1; 
         regsrcsel_dx = 2'b11;
         immsrcsel_cu = 1'b1;
         immaddsel_cu = 1'b1;
         pcsel_dx = 1'b1;
      end
      default : begin
         // err_cu = 1'b1;
      end
   endcase
 
end

endmodule
