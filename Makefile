.POSIX:

CRYSTAL = crystal

test: .phony
	$(CRYSTAL) run test/*_test.cr

run:
	$(CRYSTAL) run src/chronos.cr

.phony:
