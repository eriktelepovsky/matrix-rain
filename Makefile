BUNDLE_NAME = MatrixSaver
BUNDLE      = $(BUNDLE_NAME).saver
SDK         = $(shell xcrun --sdk macosx --show-sdk-path)
ARCH        = $(shell uname -m)
TARGET      = $(ARCH)-apple-macosx13.0

SWIFTFLAGS  = \
    -sdk $(SDK) \
    -target $(TARGET) \
    -module-name MatrixScreenSaver \
    -framework ScreenSaver \
    -framework AppKit

.PHONY: all install uninstall clean

all: $(BUNDLE)

$(BUNDLE): MatrixScreenSaver.swift Info.plist index.html
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Resources
	swiftc MatrixScreenSaver.swift $(SWIFTFLAGS) -Xlinker -bundle -o $(BUNDLE)/Contents/MacOS/$(BUNDLE_NAME)
	cp Info.plist $(BUNDLE)/Contents/Info.plist
	cp index.html $(BUNDLE)/Contents/Resources/index.html

install: all
	rm -rf ~/Library/Screen\ Savers/$(BUNDLE)
	cp -R $(BUNDLE) ~/Library/Screen\ Savers/
	@echo "Installed. Open System Settings > Screen Saver to activate."

uninstall:
	rm -rf ~/Library/Screen\ Savers/$(BUNDLE)

clean:
	rm -rf $(BUNDLE)
