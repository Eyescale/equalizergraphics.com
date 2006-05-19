
TOP = ..

TARGET = ~/Sites/www.equalizergraphics.com

PAGES = \
	api.html \
	architecture.html \
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
	include/header.html \
	include/footer.html

TARGETS = $(PAGES:%=$(TARGET)/%)

EXTRA_SRC = $(wildcard images/*png) $(wildcard documents/*) \
            robots.txt stylesheet.css
EXTRA = $(EXTRA_SRC:%=$(TARGET)/%) \
	$(TARGET)/documents/An_Analysis_of_Parallel_Rendering_Systems.pdf

all: $(TARGETS) $(INCLUDES) $(EXTRA)

install: all
	rsync -avz -e ssh $(TARGET) eile@in-zueri.ch:var/www/htdocs/

.SUFFIXES: .html .css

$(TARGETS):  $(INCLUDES)

$(TARGET)/%.html : %.html
	@mkdir -p $(TARGET)
	gcc -xc -E -DUPDATE="`date +'%e. %B %Y'`" -Iinclude $< | \
		sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/An_Analysis_of_Parallel_Rendering_Systems.pdf: ../../doc/WhitePapers/ParallelRenderingSystems/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp $< $@
