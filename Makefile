
TOP = ..

TARGET = build

PAGES = \
	api.html \
	configuration.html \
	contact.html \
	documentation.html \
	downloads.html \
	impressum.html \
	index.html \
	lists.html \
	news.html \
	scalability.html

INCLUDES = \
	include/header.shtml \
	include/footer.shtml

TARGETS = $(PAGES:%=$(TARGET)/%)

EXTRA_SRC = $(wildcard images/*png) $(wildcard documents/*) \
            robots.txt stylesheet.css
EXTRA = $(EXTRA_SRC:%=$(TARGET)/%) \
	$(TARGET)/documents/ParallelRenderingSystems.pdf \
	$(TARGET)/documents/ProjectEqualizer.pdf

all: $(TARGETS) $(INCLUDES) $(EXTRA)

install: all
	rsync -avz -e ssh $(TARGET)/ eile@in-zueri.ch:var/www/htdocs/www.equalizergraphics.com

.SUFFIXES: .html .css

$(TARGETS):  $(INCLUDES)

$(TARGET)/%.html : %.shtml
	@mkdir -p $(TARGET)
	gcc -xc -ansi -E -DUPDATE="`date +'%e. %B %Y'`" -Iinclude $< | \
		sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/%.pdf: ../../doc/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp $< $@
