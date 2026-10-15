// SPDX-License-Identifier: GPL-2.0
/*
 * Set ICP_SECOND_PPS_IO_SELECT before i915 probes the second eDP.
 * On this Alder Lake-P the BIOS leaves SOUTH_CHICKEN1 bit 2 clear, so
 * i915 drops DDI B with "unusable PPS, disabling eDP".
 * Load via: softdep i915 pre: i915_second_pps
 */

#include <linux/io.h>
#include <linux/module.h>
#include <linux/pci.h>

#define ADL_P_GT2 0x46a6
#define SOUTH_CHICKEN1 0xc2000u
#define SECOND_PPS BIT(2)

static int __init i915_second_pps_init(void)
{
	struct pci_dev *pdev;
	void __iomem *regs;
	resource_size_t start, len;
	u32 val, now;

	pdev = pci_get_device(PCI_VENDOR_ID_INTEL, ADL_P_GT2, NULL);
	if (!pdev) {
		pr_info("i915_second_pps: 8086:46a6 not found, nothing to do\n");
		return 0;
	}

	start = pci_resource_start(pdev, 0);
	len = pci_resource_len(pdev, 0);
	if (!start || len < SOUTH_CHICKEN1 + 4) {
		pr_info("i915_second_pps: BAR0 not usable\n");
		goto out;
	}

	regs = ioremap(start, len);
	if (!regs) {
		pr_info("i915_second_pps: ioremap failed\n");
		goto out;
	}

	val = ioread32(regs + SOUTH_CHICKEN1);
	if (val == 0xffffffff) {
		pr_info("i915_second_pps: SOUTH_CHICKEN1 not readable, left unchanged\n");
	} else if (val & SECOND_PPS) {
		pr_info("i915_second_pps: second PPS already enabled (%#x)\n", val);
	} else {
		iowrite32(val | SECOND_PPS, regs + SOUTH_CHICKEN1);
		now = ioread32(regs + SOUTH_CHICKEN1);
		pr_info("i915_second_pps: SOUTH_CHICKEN1 %#x -> %#x\n", val, now);
	}

	iounmap(regs);
out:
	pci_dev_put(pdev);
	return 0;
}

static void __exit i915_second_pps_exit(void)
{
}

module_init(i915_second_pps_init);
module_exit(i915_second_pps_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Enable the second Alder Lake panel power sequencer");
