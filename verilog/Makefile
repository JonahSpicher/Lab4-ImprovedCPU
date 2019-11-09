# Simple Verilog simulation Makefile example

ICARUS_OPTIONS := -Wall
IVERILOG := iverilog $(ICARUS_OPTIONS)
SIM := vvp

CIRCUITS := cpu.v
CIRCUITS2 := alu.v
CIRCUITS3 := decoders.v
CIRCUITS4 := regfile.v
CIRCUITS5 := LUT.v
CIRCUITS6 := multiplexer.v
TEST := cpu
TEST2 := alu
TEST3 := decoders
TEST4 := regfile
TEST5 := LUT
TEST6 := multiplexer

# Pattern rule for compiling vvp (Icarus assembly) from a testbench
%.vvp: %.t.v $(CIRCUITS)
	$(IVERILOG) -o $@ $<

%.vvp: %.t.v $(CIRCUITS2)
	$(IVERILOG) -o $@ $<

%.vvp: %.t.v $(CIRCUITS3)
	$(IVERILOG) -o $@ $<

%.vvp: %.t.v $(CIRCUITS4)
	$(IVERILOG) -o $@ $<

%.vvp: %.t.v $(CIRCUITS5)
	$(IVERILOG) -o $@ $<

%.vvp: %.t.v $(CIRCUITS6)
	$(IVERILOG) -o $@ $<


# Shortcut (phony) targets for convenience
compile: $(TEST).vvp #creates cpu.vvp

run: $(TEST).vvp #Runs cpu.t.v
	$(SIM) $<

runLUT: $(TEST5).vvp #Runs LUT, which does not self test for success.
	$(SIM) $<

runMux: $(TEST6).vvp #Runs multiplexers
	$(SIM) $<


clean:
	-rm -f $(TEST).vvp
	-rm -f $(TEST2).vvp
	-rm -f $(TEST3).vvp
	-rm -f $(TEST4).vvp
	-rm -f $(TEST5).vvp
	-rm -f $(TEST6).vvp

runAll: $(TEST).vvp $(TEST2).vvp $(TEST3).vvp $(TEST4).vvp $(TEST5).vvp #Use to run every test (not recommended, hard to parse)
	$(SIM) $<
	$(SIM) $(TEST2).vvp
	$(SIM) $(TEST3).vvp
	$(SIM) $(TEST4).vvp
	$(SIM) $(TEST5).vvp

runAuto: $(TEST).vvp $(TEST2).vvp $(TEST3).vvp $(TEST4).vvp $(TEST6).vvp #Use to run every automated test with self reported success, recommended
	$(SIM) $<
	$(SIM) $(TEST2).vvp
	$(SIM) $(TEST3).vvp
	$(SIM) $(TEST4).vvp
	$(SIM) $(TEST6).vvp

.PHONY: compile run clean runLUT runAll runAuto
