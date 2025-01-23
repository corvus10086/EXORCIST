SUBDIRS := $(shell ls -d src/*)

all:
	
	@for subdir in $(SUBDIRS); do \
		make -C $$subdir;\
	done
	
clean:
	@for subdir in $(SUBDIRS); do \
		make -C $$subdir clean;\
	done