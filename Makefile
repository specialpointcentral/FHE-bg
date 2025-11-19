LATEX=pdflatex
TARGET=main

.PHONY: all clean notes

all: $(TARGET).pdf $(TARGET)-notes.pdf

$(TARGET).pdf: $(TARGET).tex
	$(LATEX) -interaction=nonstopmode $(TARGET).tex
	$(LATEX) -interaction=nonstopmode $(TARGET).tex

$(TARGET)-notes.pdf: $(TARGET).tex
	$(LATEX) -interaction=nonstopmode -jobname=$(TARGET)-notes "\def\shownotes{}\input{$(TARGET).tex}"
	$(LATEX) -interaction=nonstopmode -jobname=$(TARGET)-notes "\def\shownotes{}\input{$(TARGET).tex}"

notes: $(TARGET)-notes.pdf

clean:
	rm -f $(TARGET).aux $(TARGET).log $(TARGET).nav \
		$(TARGET).out $(TARGET).snm $(TARGET).toc $(TARGET).vrb $(TARGET).pdf \
		$(TARGET)-notes.aux $(TARGET)-notes.log $(TARGET)-notes.nav \
		$(TARGET)-notes.out $(TARGET)-notes.snm $(TARGET)-notes.toc \
		$(TARGET)-notes.vrb $(TARGET)-notes.pdf
