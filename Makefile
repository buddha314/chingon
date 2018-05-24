include local.mk
CC=chpl
MODULES=-M$(NUMSUCH_HOME)/src -M$(CHREST_HOME)/src -M$(CHARCOAL_HOME)/src 
INCLUDES = -I/usr/include -I$(BLAS_HOME)/include -I$(POSTGRES_HOME)
LIBS=-L$(BLAS_HOME)/lib -lblas
FLAGS=--fast --print-callstack-on-error --print-commands
SRCDIR=src
BINDIR=bin
TESTDIR=test
CHINGON_EXEC=chingon

default: $(SRCDIR)/Chingon.chpl
	$(CC) $(MODULES) $(FLAGS) ${INCLUDES} ${LIBS} -o $(BINDIR)/$(CHINGON_EXEC) $<

run-test: test

test: $(TESTDIR)/ChingonTest.chpl
	$(CC) -M$(SRCDIR) $(MODULES) $(FLAGS) ${INCLUDES} ${LIBS} -o $(TESTDIR)/test $< ; \
	./$(TESTDIR)/test; \
	rm $(TESTDIR)/test
