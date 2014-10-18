SQUASHFS3_VERSION:=3.4
SQUASHFS3_SOURCE:=squashfs$(SQUASHFS3_VERSION).tar.gz
SQUASHFS3_SOURCE_MD5:=2a4d2995ad5aa6840c95a95ffa6b1da6
SQUASHFS3_SITE:=@SF/squashfs

SQUASHFS3_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs3
SQUASHFS3_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS3_VERSION)
SQUASHFS3_BUILD_DIR:=$(SQUASHFS3_DIR)/squashfs-tools

SQUASHFS3_TOOLS:=mksquashfs3 unsquashfs3 mksquashfs3-lzma unsquashfs3-lzma
SQUASHFS3_TOOLS_BUILD_DIR:=$(addprefix $(SQUASHFS3_BUILD_DIR)/,$(SQUASHFS3_TOOLS))
SQUASHFS3_TOOLS_TARGET_DIR:=$(addprefix $(TOOLS_DIR)/,$(SQUASHFS3_TOOLS))

squashfs3-source: $(DL_DIR)/$(SQUASHFS3_SOURCE)
$(DL_DIR)/$(SQUASHFS3_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS3_SOURCE) $(SQUASHFS3_SITE) $(SQUASHFS3_SOURCE_MD5)

squashfs3-unpacked: $(SQUASHFS3_DIR)/.unpacked
$(SQUASHFS3_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS3_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS3_SOURCE),$(TOOLS_SOURCE_DIR))
	for i in $(SQUASHFS3_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(SQUASHFS3_DIR) $$i; \
	done
	touch $@

$(SQUASHFS3_TOOLS_BUILD_DIR): $(SQUASHFS3_DIR)/.unpacked $(LZMA_DIR)/liblzma.a
	$(MAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" LZMA_DIR="$(abspath $(LZMA_DIR))" \
		-C $(SQUASHFS3_BUILD_DIR) all
	touch -c $@

$(SQUASHFS3_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%: $(SQUASHFS3_BUILD_DIR)/%
	$(INSTALL_FILE)
	strip $@

squashfs3: $(SQUASHFS3_TOOLS_TARGET_DIR)

squashfs3-clean:
	-$(MAKE) -C $(SQUASHFS3_BUILD_DIR) clean

squashfs3-dirclean:
	$(RM) -r $(SQUASHFS3_DIR)

squashfs3-distclean: squashfs3-dirclean
	$(RM) $(SQUASHFS3_TOOLS_TARGET_DIR)