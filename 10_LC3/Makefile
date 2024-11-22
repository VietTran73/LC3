VLIB = vlib
VMAP = vmap
WORK_LIB = work
VLOG = vlog -work
VSIM = vsim -c 
RUN = -do "run -all"

SRC = $(wildcard srcs/*)
SRC_V = $(filter %.v, $(SRC))

TB_FET = $(wildcard tb/fetch/*)
TB_FET_V = $(filter %.v, $(TB_FET))
NAME_TB = $(notdir $(basename $(TB_FET_V)))

# notdir láy tên sau cùng cua pwd
# basename is bo duoi .v di

all: init compile sim_apb sim_counter report 

init:
	$(VLIB) $(WORK_LIB)
	$(VMAP) work $(WORK_LIB)
	@mkdir -p output 
compile:
	$(VLOG)	$(WORK_LIB) $(SRC_V)	
	$(VLOG) $(WORK_LIB) $(TB_FET_V)

sim_apb: $(NAME_TB)
	@echo "simulation complete"
$(NAME_TB):
	$(VSIM) $(WORK_LIB).$@ $(RUN)

# $@: lay ten cua target

report:
	@./report.sh
clean:
	@rm -rf output work transcript modelsim.ini report.txt
