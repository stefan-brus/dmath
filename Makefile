# Common for all targets
COMMON_SRC = src/core/absyn/Expression.d src/core/absyn/ExpressionBuilder.d \
	src/core/absyn/util/Function.d src/core/absyn/util/ExpTree.d \
	src/core/parser/Grammar.d src/core/parser/Parser.d \
	src/core/runtime/Commands.d src/core/runtime/Constants.d \
	src/core/symtab/Symbols.d src/core/symtab/SymbolTable.d \
    src/core/util/Array.d src/core/util/File.d src/core/util/JSON.d src/core/util/String.d \
    src/core/util/app/Application.d src/core/util/app/Arguments.d \
    src/core/util/container/Stack.d src/core/util/container/Queue.d src/core/util/container/HashMap.d \
    src/core/util/dmath/FileParser.d src/core/util/dmath/StateSaver.d src/core/util/dmath/StringEvaluator.d \
    src/core/util/tmpl/Singleton.d


# Pegged source files
PEGGED_SRC = Pegged/pegged/peg.d Pegged/pegged/grammar.d Pegged/pegged/parser.d \
	Pegged/pegged/dynamic/grammar.d Pegged/pegged/dynamic/peg.d


# Main target
MAIN_TARGET = src/main/dmath.d src/mod/DMath.d $(COMMON_SRC) $(PEGGED_SRC)


# Test target
TEST_TARGET = src/main/test.d src/mod/Test.d $(COMMON_SRC) $(PEGGED_SRC)


# dmd flags
DCC = dmd
DFLAGS = -debug -g -unittest


# Targets
all: $(MAIN_TARGET)
	$(DCC) $(MAIN_TARGET) $(DFLAGS)

test: $(TEST_TARGET)
	$(DCC) $(TEST_TARGET) $(DFLAGS)