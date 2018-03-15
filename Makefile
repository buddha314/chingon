include local.mk
CC=chpl
MODULES=-M$(CDO_HOME)/src -M$(NUMSUCH_HOME)/src -M$(CHREST_HOME)/src -M$(CHARCOAL_HOME)/src
INCLUDES = -I/usr/include -I$(BLAS_HOME)/include -I$(POSTGRES_HOME)
LIBS=-L$(BLAS_HOME)/lib -lblas
FLAGS=--fast --print-callstack-on-error --print-commands
SRCDIR=src
BINDIR=bin
CHINGON_EXEC=chingon

default: $(SRCDIR)/Chingon.chpl
	$(CC) $(MODULES) $(FLAGS) ${INCLUDES} ${LIBS} -o $(BINDIR)/$(CHINGON_EXEC) $<
