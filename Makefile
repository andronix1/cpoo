.PHONY: run

.build/%: src/*.v src/isa/*.v src/tests/%.v
	iverilog $^ -o $@

.build:
	mkdir .build

run: .build .build/cpu
	.build/cpu
