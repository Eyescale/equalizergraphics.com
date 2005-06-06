
TOP = ..

TARGET = ~/Desktop/ws

PAGES =  api.out configuration.out contact.out index.out news.out scalability.out
INCLUDES = include/header.html include/footer.html
CSS = $(TARGET)/stylesheet.css

all: $(PAGES) $(CSS) $(INCLUDES)

.SUFFIXES: .html .css

.html.out: $(INCLUDES)
	gcc -xc -E -Iinclude $*.html | sed 's/^#.*//' > $@ && \
	cp $@ $(TARGET)/$*.html

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@