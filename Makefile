# Common for all targets
COMMON_SRC = src/mod/common/FileParser.d src/mod/common/StringEvaluator.d \
    src/core/parser/InputTokenizer.d src/core/parser/Tokens.d src/core/parser/Parser.d \
    src/core/absyn/Expression.d src/core/absyn/ExpressionBuilder.d \
    src/core/util/Array.d src/core/util/File.d src/core/util/String.d \
    src/core/util/app/Application.d src/core/util/app/Arguments.d \
    src/core/util/container/Stack.d src/core/util/container/Queue.d src/core/util/container/HashMap.d


# Main target
MAIN_TARGET = src/main/dmath.d src/mod/DMath.d $(COMMON_SRC)


# Test target
TEST_TARGET = src/main/test.d src/mod/Test.d $(COMMON_SRC)


# dmd flags
DCC = dmd
DFLAGS = -debug -gc -unittest


# Targets
all: $(MAIN_TARGET)
	$(DCC) $(MAIN_TARGET) $(DFLAGS)

test: $(TEST_TARGET)
	$(DCC) $(TEST_TARGET) $(DFLAGS)