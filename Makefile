# config
EXT_IN ?= page
EXT_OUT ?= html

# directories and files
ETC ?= $(CURDIR)/etc
CONTENT ?= $(CURDIR)/content
DEST ?= $(CURDIR)/build

FILES := $(shell find $(CONTENT) -type f)
FILES := $(FILES:.$(EXT_IN)=.$(EXT_OUT))
FILES := $(FILES:$(CONTENT)/%=$(DEST)/%)
LAYOUTS := $(shell find layouts -type f)
ALL_DEPS := $(FILES) # $(DEST)/archive.html

export PATH := .:$(PATH)

all: $(ALL_DEPS)
	@rm -f $(CONTENT)/*.meta $(CONTENT)/*.mk
.PHONY: all

$(DEST)/archive.html: $(CONTENT)/archive.meta $(CONTENT)/archive.mk $(LAYOUTS)
	@mkdir -p $(@D)
	@cat $< > build/archive_meta
	@archive >> build/archive_meta
	@jinja2 $(word 2, $^) build/archive_meta --format yaml > build/tmp # render body
	@render_page $< build/tmp > $@ # insert body in layout page

$(DEST)/%.$(EXT_OUT): $(CONTENT)/%.meta $(CONTENT)/%.mk $(LAYOUTS)
	@mkdir -p $(@D)
	@jinja2 $(word 2, $^) $< --format yaml > build/tmp # render body
	@render_page $< build/tmp > $@ # insert body in layout page
	@rm build/tmp

$(CONTENT)/%.mk: $(CONTENT)/%.$(EXT_IN)
	@cat $< | \
		fm -s | \
		pandoc -f markdown-markdown_in_html_blocks+raw_html \
		       --katex --highlight-style pygments -t html > $@

$(CONTENT)/%.meta: $(CONTENT)/%.$(EXT_IN)
	@cat $< | fm > $@


$(DEST)/%: $(CONTENT)/%
	@mkdir -p $(@D)
	@cp $< $@

.PHONY: clean
clean:
	@mv build/.git ./.deploy_git
	@rm -rf build/
	@mkdir build
	@mv ./.deploy_git build/.git

