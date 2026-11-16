TOOLCHAIN   := $(OO_PS4_TOOLCHAIN)
PROJDIR     := $(shell pwd)
INTDIR      := $(PROJDIR)/build
OUTDIR      := $(PROJDIR)

TARGET      := eboot.bin
PKG_TITLE   := Controller Bridge
PKG_ID      := CNTR00001

CFILES      := $(wildcard source/*.c)
CPPFILES    := $(wildcard source/*.cpp)
OBJS        := $(patsubst source/%.c, $(INTDIR)/%.o, $(CFILES)) $(patsubst source/%.cpp, $(INTDIR)/%.o, $(CPPFILES))

LIBS        := -lc -lkernel -lc++ -lSceUserService -lScePad -lSceUsbd

CC          := clang
CXX         := clang++
LD          := ld.lld
CFLAGS      := --target=x86_64-pc-freebsd12-elf -fPIC -funwind-tables -I$(TOOLCHAIN)/include -Iinclude -O2
CXXFLAGS    := $(CFLAGS) -std=c++17
LDFLAGS     := -m elf_x86_64 -pie --script $(TOOLCHAIN)/link.x --eh-frame-hdr -L$(TOOLCHAIN)/lib $(LIBS) $(TOOLCHAIN)/lib/crt1.o

all: $(OUTDIR)/$(TARGET)

$(OUTDIR)/$(TARGET): $(OBJS)
	$(LD) $(OBJS) -o $(INTDIR)/$(TARGET).elf $(LDFLAGS)
	$(TOOLCHAIN)/bin/linux/create-fself -in=$(INTDIR)/$(TARGET).elf -out=$(OUTDIR)/$(TARGET) --paid 0x3800000000000011

$(INTDIR)/%.o: source/%.cpp
	@mkdir -p $(INTDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

pkg:
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_new param.sfo
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo APP_TYPE --type Integer --maxsize 4 --value 1
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo APP_VER --type Utf8 --maxsize 8 --value "01.00"
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo CATEGORY --type Utf8 --maxsize 4 --value "gd"
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo CONTENT_ID --type Utf8 --maxsize 48 --value "IV0000-$(PKG_ID)_00-CONTROLLERBRIDGE"
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo TITLE --type Utf8 --maxsize 128 --value "$(PKG_TITLE)"
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo TITLE_ID --type Utf8 --maxsize 12 --value "$(PKG_ID)"
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry param.sfo VERSION --type Utf8 --maxsize 8 --value "01.00"
	mkdir -p pkg/sce_sys
	cp param.sfo pkg/sce_sys/param.sfo
	cp $(TARGET) pkg/$(TARGET)
	$(TOOLCHAIN)/bin/linux/PkgTool.Core pkg_build pkg .

clean:
	rm -rf $(INTDIR) $(TARGET) param.sfo pkg *.pkg
