
TOP = ..

TARGET = build

FILES = \
	api.html \
	configuration.html \
	contact.html \
	documentation.html \
	doc_developer.html \
	downloads.html \
	impressum.html \
	index.html \
	lists.html \
	news.html \
	scalability.html \
	$(wildcard images/*png) \
	$(wildcard documents/*) \
        robots.txt \
	stylesheet.css \
	favicon.ico \
	documents/WhitePapers/ParallelRenderingSystems.pdf \
	documents/WhitePapers/ProjectEqualizer.pdf \
	documents/design/compounds.html \
	documents/design/frames.html \
	documents/design/frames.png \
	documents/design/nodeFailure.html \
	documents/design/threads.txt

INCLUDES = \
	include/header.shtml \
	include/footer.shtml

TARGETS = $(FILES:%=$(TARGET)/%) 

all: $(TARGETS) $(INCLUDES)

clean:
	rm -rf $(TARGETS)

install: all
	rsync -avz --exclude=".svn" -e ssh $(TARGET)/ eile@equalizergraphics.com:var/www/htdocs/www.equalizergraphics.com

.SUFFIXES: .html .css

$(TARGET)/%.html : %.shtml  $(INCLUDES)
	@mkdir -p $(@D)
	gcc -xc -ansi -E -DUPDATE="`date +'%e. %B %Y'`" -Iinclude $< | \
		sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/WhitePapers/%.pdf: ../doc/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/design/%.html : ../doc/design/%.shtml $(INCLUDES)
	@mkdir -p $(@D)
	gcc -xc -ansi -E -DUPDATE="`date +'%e. %B %Y'`" -DBASE -Iinclude $< | \
		sed 's/^#.*//' > $@

$(TARGET)/documents/%: ../doc/%
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp $< $@
