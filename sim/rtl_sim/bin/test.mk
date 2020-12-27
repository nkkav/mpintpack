GHDL=ghdl
GHDLFLAGS=--ieee=standard -fexplicit --workdir=work
# Simulation will run up to this limit and end by the forced assert.
GHDLRUNFLAGS=--stop-time=410ns

# Default target : run
all : run

# Elaborate target.  Almost useless
elab : force
	$(GHDL) -c $(GHDLFLAGS) -e $(TEST)

# Run target
run : force
	$(GHDL) --elab-run $(GHDLFLAGS) $(TEST) $(GHDLRUNFLAGS) | tee $(TEST)_results.txt

# Targets to analyze libraries
init : force
	mkdir work
	$(GHDL) -a $(GHDLFLAGS) ../../../rtl/vhdl/mpint.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../../bench/vhdl/$(TEST).vhd

force : 

clean :
	rm -rf *.o work $(TEST)_results.txt
