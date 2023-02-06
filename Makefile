LDID           = $(shell command -v ldid)
STRIP          = $(shell command -v strip)

IPOD_TMP         = $(TMPDIR)/iPod
IPOD_STAGE_DIR   = $(IPOD_TMP)/stage
IPOD_APP_DIR     = $(IPOD_TMP)/Build/Products/Release-iphoneos/iPod.app

.PHONY: package

package:
	# Build
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'iPod.xcodeproj' -scheme iPod -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(IPOD_TMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(IPOD_TMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	
	@rm -rf Payload
	@rm -rf $(IPOD_STAGE_DIR)/
	@mkdir -p $(IPOD_STAGE_DIR)/Payload
	@mv $(IPOD_APP_DIR) $(IPOD_STAGE_DIR)/Payload/iPod.app

	# Prepare
	@echo $(IPOD_TMP)
	@echo $(IPOD_STAGE_DIR)

	@$(STRIP) $(IPOD_STAGE_DIR)/Payload/iPod.app/iPod
	@$(LDID) -SiPod/iPod.entitlements $(IPOD_STAGE_DIR)/Payload/iPod.app/
	
	@rm -rf $(IPOD_STAGE_DIR)/Payload/iPod.app/_CodeSignature

	@ln -sf $(IPOD_STAGE_DIR)/Payload Payload

	# Clean
	@rm -rf packages
	@mkdir -p packages

	# Zip
	@zip -r9 packages/iPod.ipa Payload
	@rm -rf Payload