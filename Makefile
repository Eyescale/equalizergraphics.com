#!gmake
all:
	@$(MAKE) -C ../.. equalizergraphics-buildonly

install:
	@$(MAKE) -C ../.. equalizergraphics-install

configure:
	@$(MAKE) -C ../.. equalizergraphics-configure

test:
	@$(MAKE) -C ../.. equalizergraphics-test

.DEFAULT:
	@$(MAKE) -C ../.. $(MAKECMDGOALS)
