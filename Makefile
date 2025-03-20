.PHONY: run

.build/%: src/*.v src/isa/*.v src/tb/%.v
	iverilog $^ -o $@

.build:
	mkdir .build

run: .build .build/cpu
	.build/cpu
