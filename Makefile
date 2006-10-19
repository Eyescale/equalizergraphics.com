
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
	useCases.html \
	$(wildcard images/*png) \
        robots.txt \
	stylesheet.css \
	favicon.ico \
	documents/CV_Stefan_Eilemann.pdf \
	documents/Projects_Stefan_Eilemann.pdf \
	documents/Equalizer.pdf \
	documents/Equalizer.html \
	documents/Equalizer.html_files \
	documents/Flyer.pdf \
	documents/ParallelGraphicsProgramming.pdf \
	documents/EqualizerVizSIG06.pdf \
	documents/EqualizerVizSIG06.html \
	documents/EqualizerVizSIG06.html_files \
	documents/EqualizerTeaser.pdf \
	documents/EqualizerTeaser.html \
	documents/EqualizerTeaser.html_files \
	documents/WhitePapers/ParallelRenderingSystems.pdf \
	documents/WhitePapers/ProjectEqualizer.pdf \
	documents/design/codingStyle.png \
	documents/design/compounds.html \
	documents/design/fileFormat.html \
	documents/design/frames.html \
	documents/design/frames.png \
	documents/design/nodeFailure.html \
	documents/design/packets.html \
	documents/design/packets.png \
	documents/design/threads.txt \
	documents/glAsync/CHANGELOG \
	documents/glAsync/annotated.html \
	documents/glAsync/classglAsync_1_1Thread-members.html \
	documents/glAsync/classglAsync_1_1Thread.html \
	documents/glAsync/doxygen.css \
	documents/glAsync/doxygen.png \
	documents/glAsync/files.html \
	documents/glAsync/functions.html \
	documents/glAsync/functions_func.html \
	documents/glAsync/glAsync_8h-source.html \
	documents/glAsync/glAsync_8h.html \
	documents/glAsync/globals.html \
	documents/glAsync/globals_defs.html \
	documents/glAsync/globals_func.html \
	documents/glAsync/hierarchy.html \
	documents/glAsync/index.html \
	documents/glAsync/namespaceglAsync.html \
	documents/glAsync/namespacemembers.html \
	documents/glAsync/namespacemembers_func.html \
	documents/glAsync/namespaces.html \
	documents/glAsync/tab_b.gif \
	documents/glAsync/tab_l.gif \
	documents/glAsync/tab_r.gif \
	documents/glAsync/tabs.css \
	downloads

INCLUDES = \
	include/header.shtml \
	include/footer.shtml

TARGETS  = $(FILES:%=$(TARGET)/%) 
CPP_HTML = gcc -xc -traditional-cpp -ansi -E -DUPDATE="`date +'%e. %B %Y'`" -Iinclude

all: $(TARGETS) $(INCLUDES)

clean:
	rm -rf $(TARGETS)

install: all
	rsync -avz --exclude=".svn" -e ssh $(TARGET)/ eile@equalizergraphics.com:var/www/htdocs/www.equalizergraphics.com

.SUFFIXES: .html .css

$(TARGET)/%.html : %.shtml  $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) $< | sed 's/^#.*//' > $@

$(TARGET)/stylesheet.css: stylesheet.css
	cp stylesheet.css $@

$(TARGET)/documents/WhitePapers/%.pdf: ../doc/WhitePapers/%/paper.pdf
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/documents/design/%.html : ../doc/design/%.shtml $(INCLUDES)
	@mkdir -p $(@D)
	$(CPP_HTML) -DBASE $< | sed 's/^#.*//' > $@

$(TARGET)/documents/%: ../doc/%
	@mkdir -p $(@D)
	cp $< $@

$(TARGET)/% : %
	@mkdir -p $(@D)
	cp -r $< $(@D)
