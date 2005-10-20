
TOP = ..

TARGET = ~/Sites/www.equalizergraphics.com

PAGES = \
	api.html \
	architecture.html \
	configuration.html \
	contact.html \
	index.html \
	news.html \
	scalability.html

INCLUDES = \
	include/header.html \
	include/footer.html

TARGETS = $(PAGES:%=$(TARGET)/%)

CSS = $(TARGET)/stylesheet.css

EXTRA_SRC = $(wildcard images/*png) $(wildcard documents/*)
EXTRA = $(EXTRA_SRC:%=$(TARGET)/%)

all: $(TARGETS) $(CSS) $(INCLUDES) $(EXTRA)

.SUFFIXES: .html .css

$(TARGETS):  $(INCLUDES)

$(TARGET)/%.html : %.html
	@mkdir -p $(TARGET)
	gcc -xc -E -DUPDATE="`date +'%e. %B %Y'`" -Iinclude $< | \
		sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/% : %
	@mkdir -p $(TARGET)/images
	cp $< $@
