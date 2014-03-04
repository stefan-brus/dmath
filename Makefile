# Main target
MAIN_TARGET = src/main/dmath.d \
    src/mod/DMath.d \
    src/core/parser/InputTokenizer.d src/core/parser/Tokens.d src/core/parser/Parser.d \
    src/core/absyn/Expression.d \
    src/core/util/Array.d \
    src/core/util/container/Stack.d src/core/util/container/Queue.d
MAIN_OUTPUT = bin/dmath.exe
MAIN_EXE = dmath.exe


# dmd flags
DCC = dmd
DFLAGS = -debug -gc -unittest


# Targets
all: $(MAIN_TARGET)
	$(DCC) $(MAIN_TARGET) $(DFLAGS)
