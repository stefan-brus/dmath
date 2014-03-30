# Common for all targets
COMMON_SRC = src/dmath/absyn/Expression.d src/dmath/absyn/ExpressionBuilder.d \
	src/dmath/absyn/util/Function.d src/dmath/absyn/util/ExpTree.d \
	src/dmath/parser/Grammar.d src/dmath/parser/Parser.d \
	src/dmath/runtime/Commands.d src/dmath/runtime/Constants.d \
	src/dmath/symtab/Symbols.d src/dmath/symtab/SymbolTable.d \
    src/dmath/util/Array.d src/dmath/util/File.d src/dmath/util/JSON.d src/dmath/util/String.d \
    src/dmath/util/app/Application.d src/dmath/util/app/Arguments.d \
    src/dmath/util/container/Stack.d src/dmath/util/container/Queue.d src/dmath/util/container/HashMap.d \
    src/dmath/util/dmath/FileParser.d src/dmath/util/dmath/StateSaver.d src/dmath/util/dmath/StringEvaluator.d \
    src/dmath/util/tmpl/Singleton.d


# Pegged source files
PEGGED_SRC = Pegged/pegged/peg.d Pegged/pegged/grammar.d Pegged/pegged/parser.d \
	Pegged/pegged/dynamic/grammar.d Pegged/pegged/dynamic/peg.d


# Main target
MAIN_TARGET = src/dmath/DMath.d $(COMMON_SRC) $(PEGGED_SRC)


# Test target
TEST_TARGET = src/dmath/Test.d $(COMMON_SRC) $(PEGGED_SRC)


# dmd flags
DCC = dmd
DFLAGS = -debug -g -unittest


# Targets
all: $(MAIN_TARGET)
	$(DCC) $(MAIN_TARGET) $(DFLAGS)

test: $(TEST_TARGET)
	$(DCC) $(TEST_TARGET) $(DFLAGS)