include theos/makefiles/common.mk

TWEAK_NAME = FetchMyLyrics
FetchMyLyrics_FILES = classes/FMLHook.xm \
					  classes/FMLController.xm \
					  classes/FMLOperation.xm \
					  classes/FMLLyricsWrapper.xm \
					  classes/FMLLyricsWikiOperation.xm \
					  classes/FMLLyricsWikiAPIParser.xm \
					  classes/FMLLyricsWikiPageParser.xm \
					  classes/FMLAZLyricsOperation.xm \
					  classes/FMLAZLyricsPageParser.xm
FetchMyLyrics_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
FetchMyLyrics_PRIVATE_FRAMEWORKS = iPodUI

CFLAGS = -I./classes -I./ext -I./headers -I/usr/include/objc 

include $(THEOS_MAKE_PATH)/tweak.mk
