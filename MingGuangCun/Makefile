# Makefile

# Compiler settings
CC = gcc
CFLAGS =   -O1
LDFLAGS = -L. -lm

# Project directories
PROJECTS = ldpc FFT music Mod-Demod

# Default target
all: $(PROJECTS)

# Phony targets
.PHONY: all clean $(PROJECTS)

# Enable FPGA options
# FPGA_ENABLED ?= 0

# FPGA-specific flags
ifeq ($(FPGA_ENABLED), 1)
    FPGA_FLAGS = -DFPGA
endif

# Compile each project
$(PROJECTS):
	@echo "Compiling $@..."
	@$(CC) $(CFLAGS) $(FPGA_FLAGS) $@/src/test.c -o $@/test $(LDFLAGS)
	@echo "Compilation of $@ completed."

# Clean target
clean:
	@echo "Cleaning up..."
	@for dir in $(PROJECTS); do \
		rm -f $$dir/test; \
		echo "Cleaned $$dir"; \
	done
	@echo "Cleanup completed."