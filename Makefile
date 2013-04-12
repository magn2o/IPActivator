export ARCHS=armv7 
export TARGET=iphone:latest:4.3

include theos/makefiles/common.mk

TWEAK_NAME = IPActivator
IPActivator_FILES = Tweak.xm
IPActivator_FRAMEWORKS = Foundation UIKit
#IPActivator_LDFLAGS = -lactivator -Llib/
IPActivator_LDFLAGS = -lactivator

include $(FW_MAKEDIR)/tweak.mk
