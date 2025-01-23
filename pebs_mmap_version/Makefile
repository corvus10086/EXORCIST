engine=${PWD}/beaengine

COMPILER_OPTIONS :=  -Wall \
	-Wframe-larger-than=4608 -fno-stack-protector -z execstack
EXTRA_CFLAGS := -I${engine}/include \
	-I${engine}/include/beaengine -I${engine}/src ${COMPILER_OPTIONS}

obj-m := pebs.o
pebs-objs := pebs_message_send.o pebs_buffer.o pebs_taine_tool.o pebs_taine.o pebs_init.o

KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
clean:
	rm -rf *.o .*.o.d *.mod.c *.ko *.symvers *.order *.makers *.mod .*.*.cmd
