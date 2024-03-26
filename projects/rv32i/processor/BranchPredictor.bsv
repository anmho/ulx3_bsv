import Vector::*;
import Defines::*;

interface BranchPredictorIfc;
	method Word getNextPc(Word curpc);
	method Action setPrediction(Word curpc, Word nextpc);
endinterface

typedef 256 TableSize;

module mkBranchPredictor(BranchPredictorIfc);
	Reg#(Vector#(TableSize, Bit#(2))) bht <- mkReg(replicate(2'b00));
	Reg#(Vector#(TableSize, Word)) btb <- mkReg(replicate(0));
	method Word getNextPc(Word curpc);
		Word r = curpc + 4;
		Bit#(TLog#(TableSize)) idx = truncate(curpc);
        // Weak taken or strong taken
		if ( bht[idx] >= 2'b10) r = btb[idx];
        // if its false then return curpc + 4
        // if its true then return the stored instruction

		return r;
	endmethod
	method Action setPrediction(Word curpc, Word nextpc);
		Bit#(TLog#(TableSize)) idx = truncate(curpc);

        // if (btb[idx] != nextpc) begin
        if (btb[idx] != nextpc) begin
            $display("Branch: Mispredict\n");
            // should not have predicted
            // instead of setting it decrement if its wrong and increment if its right
            // do reverse of whatever you did before
            
            // if (bht[idx] != 2'b00) bht[idx] <= bht[idx] - 1;
        end
        else begin
            $display("Branch: Correct \n");
            // if (bht[idx] != 2'b11) bht[idx] <= bht[idx] + 1;
        end

        if (nextpc == curpc + 4) begin
            // bht[idx] <= False;
            if (bht[idx] != 2'b00) bht[idx] <= bht[idx] - 1;

        end
        else begin
            // bht[idx] <= True;
            if (bht[idx] != 2'b11) bht[idx] <= bht[idx] + 1;
        end        


		// bht[idx] <= True;
		btb[idx] <= nextpc;
	endmethod
endmodule
