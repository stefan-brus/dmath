# Main target
MAIN_TARGET = src/main/dmath.d src/mod/DMath.d src/core/parser/InputTokenizer.d src/core/parser/Tokens.d
MAIN_OUTPUT = bin/dmath.exe
MAIN_EXE = dmath.exe


# dmd flags
DCC = dmd
DFLAGS = -debug -gc


# Targets
all: $(MAIN_TARGET)
	$(DCC) $(MAIN_TARGET) $(DFLAGS)
