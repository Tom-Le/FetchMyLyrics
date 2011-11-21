include theos/makefiles/common.mk

TWEAK_NAME = LyricsGrabber
LyricsGrabber_FILES = classes/LGRHook.xm \
					  classes/LGRController.xm \
					  classes/LGROperation.xm \
					  classes/LGRLyricsWrapper.xm \
					  classes/LGRLyricsWikiOperation.xm \
					  classes/LGRLyricsWikiAPIParser.xm \
					  classes/LGRLyricsWikiPageParser.xm
LyricsGrabber_FRAMEWORKS = Foundation UIKit MediaPlayer CoreGraphics
LyricsGrabber_PRIVATE_FRAMEWORKS = iPodUI

CFLAGS = -I./classes -I/usr/include/objc -I./headers
LDFLAGS = -F./Frameworks -F./PrivateFrameworks

include $(THEOS_MAKE_PATH)/tweak.mk
