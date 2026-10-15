obj-m += i915_second_pps.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

install:
	$(CURDIR)/install.sh

uninstall:
	$(CURDIR)/uninstall.sh

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
