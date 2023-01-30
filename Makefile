
UPX ?= upx
ZX7 ?= z88dk-zx7

SRC := src/3rdparty/*.s src/audio/*.s src/compat/*.s src/maingame/*.s src/system/*.s src/video/*.s

MAPS := map00.map map01.map map02.map map03.map map04.map map05.map map06.map map07.map map08.map map09.map map10.map map11.map map12.map map13.map
MAPS1 := map00.map map01.map map02.map map04.map map05.map map06.map map08.map map09.map map10.map map11.map map12.map map13.map
MAPS2 := map03.map map07.map

MUSIC_ADLIB := a_lose.bin a_menu.bin a_mus01.bin a_mus02.bin a_mus03.bin a_mus04.bin a_mus05.bin a_mus06.bin a_mus07.bin a_win.bin
MUSIC_TANDY := t_lose.bin t_menu.bin t_mus01.bin t_mus02.bin t_mus03.bin t_mus04.bin t_mus05.bin t_mus06.bin t_mus07.bin t_win.bin
MUSIC_SPEAKER := s_lose.bin s_menu.bin s_mus01.bin s_mus02.bin s_mus03.bin s_mus04.bin s_mus05.bin s_mus06.bin s_mus07.bin s_win.bin
MUSIC_MT32 := m_init.bin m_lose.bin m_menu.bin m_mus01.bin m_mus02.bin m_mus03.bin m_mus04.bin m_mus05.bin m_mus06.bin m_mus07.bin m_win.bin m_andrs1.bin m_andrs2.bin m_andrs3.bin m_andrs4.bin
MUSIC_SC55 := g_lose.bin g_menu.bin g_mus01.bin g_mus02.bin g_mus03.bin g_mus04.bin g_mus05.bin g_mus06.bin g_mus07.bin g_win.bin

MUSIC_NO_MIDI := $(MUSIC_ADLIB) $(MUSIC_TANDY) $(MUSIC_SPEAKER)
MUSIC_MIDI := $(MUSIC_MT32) $(MUSIC_SC55)

TILEDESC := tiledat1.dat tiledat2.dat tiledat3.dat mirrors1.dat mirrors2.dat mirrors3.dat
FONTS := font.cga font.cmp font.vga font.cgt
SOUND := sounds.bin

# get most recent tag, suffix with distance from current commit and commit hash if the tag is not on HEAD
# the resulting string will be displayed in the program's exit message
GIT_TAG = "'$(shell git describe --always)'"

# determine whether there are uncommitted changes and write "" or " + mods" to a variable
# the resulting string will be displayed in the program's exit message
GIT_MODIFIED = "'$(shell git diff --quiet HEAD src/* || echo " + mods")'"

# synthesize a time stamp from the HEAD commit's author date and the version number (i.e. most recent tag) interpreted as time of day
# this time stamp will be used for all files on all generated disk images
GIT_TIME_FROM_TAG = $(shell git describe --abbrev=0 | sed -rE -e 's/^([0-9])\./0\1./' -e 's/\.([0-9])\./.0\1./' -e 's/\.([0-9])$$/.0\1/' -e 's/\./:/g')
DATE_ISO = $(shell git show -s --format=%cs)T$(GIT_TIME_FROM_TAG)+00:00
DATE_UNIX = $(shell date -d $(DATE_ISO) +%s)

# pass version strings to yasm and sneak in some compatibility headers
YASM_FLAGS := -I src/3rdparty/ -I src/audio/ -I src/compat/ -I src/maingame/ -I src/system/ -I src/video/ --mapfile=build/map.txt -D GIT_TAG=$(GIT_TAG) -D GIT_MODIFIED=$(GIT_MODIFIED) -P symmap.s -P pushpop.s -P emu80186.s

# environment variables for mtools: no long file names, fixed time stamps, fixed time zone
MCOPYOPTS := MTOOLS_NO_VFAT=1 SOURCE_DATE_EPOCH=$(DATE_UNIX) TZ=UTC

build/px3_ose.com: build/game_rel.com
	rm -f build/px3_ose.com
	$(UPX) --8086 -o build/px3_ose.com build/game_rel.com
	touch build/px3_ose.com

build/game_rel.com: Makefile $(SRC)
	yasm -o build/game_rel.com $(YASM_FLAGS) -f bin src/maingame/main.s

# game assets

assets: graphics maps music tiledesc fonts sound build/assets/manual.txt

# engine manual with CRLF line endings

build/assets/manual.txt: assets/manual.txt
	dos2unix -n $< $@
	unix2dos $@ $@

# generic build rule for ZX7 compressed files

build/assets/%: assets/%
	mkdir -p build/assets
	$(ZX7) -f $< $@

# maps

maps: $(addprefix build/assets/, $(MAPS))

# music

music: music_adlib music_speaker music_tandy music_sc55 music_mt32

music_adlib: $(addprefix build/assets/, $(MUSIC_ADLIB))

music_speaker: $(addprefix build/assets/, $(MUSIC_SPEAKER))

music_tandy: $(addprefix build/assets/, $(MUSIC_TANDY))

music_sc55: $(addprefix build/assets/, $(MUSIC_SC55))

music_mt32: $(addprefix build/assets/, $(MUSIC_MT32))

# sound

sound: $(addprefix build/assets/, $(SOUND))

# graphics

graphics: graphics_320x200_vga graphics_320x200_cga graphics_160x200_tdy graphics_160x200_cmp graphics_640x200_cga graphics_160x200_cgt

TILES_VGA := tile1.vga tile2.vga tile3.vga
SCREENS_VGA := menu.vga screen1.vga
TILES_CGA := tile1.cga tile2.cga tile3.cga
SCREENS_CGA := menu.cga screen1.cga
TILES_TDY := tile1.tdy tile2.tdy tile3.tdy
SCREENS_TDY := menu.tdy screen1.tdy
TILES_CMP := tile1.cmp tile2.cmp tile3.cmp
SCREENS_CMP := menu.cmp screen1.cmp
TILES_CG2 := tile1.cg2 tile2.cg2 tile3.cg2
TILES_CGT := tile1.cgt tile2.cgt tile3.cgt
SCREENS_CGT := menu.cgt screen1.cgt

TILES_ALL := $(TILES_VGA) $(TILES_CGA) $(TILES_TDY) $(TILES_CMP) $(TILES_CG2) $(TILES_CGT)
SCREENS_ALL := $(SCREENS_VGA) $(SCREENS_CGA) $(SCREENS_TDY) $(SCREENS_CMP) $(SCREENS_CGT)

graphics_320x200_vga: $(addprefix build/assets/, $(TILES_VGA) $(SCREENS_VGA))

graphics_320x200_cga: $(addprefix build/assets/, $(TILES_CGA) $(SCREENS_CGA))

graphics_160x200_tdy: $(addprefix build/assets/, $(TILES_TDY) $(SCREENS_TDY))

graphics_160x200_cmp: $(addprefix build/assets/, $(TILES_CMP) $(SCREENS_CMP))

graphics_640x200_cga: $(addprefix build/assets/, $(TILES_CG2))

graphics_160x200_cgt: $(addprefix build/assets/, $(TILES_CGT) $(SCREENS_CGT))

# tile descriptions

tiledesc: $(addprefix build/assets/, $(TILEDESC))

# fonts

fonts: $(addprefix build/assets/, $(FONTS))

px3_full: build/full_720.img build/midi_720.img build/1st_360.img build/2nd_360.img build/midi_360.img build/full1440.img build/full1200.img

# - set serial number with -N
# - TODO: set boot sector with -B
# - force a specific file date and time
# - prevent VFAT names
build/full_720.img: assets build/px3_ose.com
	mformat -i $@ -C -f 720 -v "PX3-FULL" -N "8B03720F"
	$(MCOPYOPTS) mcopy -i $@ build/px3_ose.com ::px3_ose.com
	$(MCOPYOPTS) mcopy -i $@ build/assets/manual.txt ::manual.txt
	$(MCOPYOPTS) mcopy -i $@ assets/maplist.bin ::maplist.bin
	$(foreach file,$(TILES_ALL) $(SCREENS_ALL),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_NO_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MAPS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(TILEDESC),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(FONTS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(SOUND),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/midi_720.img: assets
	mformat -i $@ -C -f 720 -v "PX3-MIDI" -N "8B03720A"
	$(foreach file,$(MUSIC_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/1st_360.img: assets build/px3_ose.com
	mformat -i $@ -C -f 360 -v "PX3-1ST" -N "8B033601"
	$(MCOPYOPTS) mcopy -i $@ build/px3_ose.com ::px3_ose.com
	$(MCOPYOPTS) mcopy -i $@ build/assets/manual.txt ::manual.txt
	$(MCOPYOPTS) mcopy -i $@ assets/maplist.bin ::maplist.bin
	$(foreach file,$(TILES_CGA) $(TILES_TDY) $(SCREENS_CGA) $(SCREENS_TDY) $(SCREENS_CMP),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_NO_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MAPS1),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(TILEDESC),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(FONTS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(SOUND),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/2nd_360.img: assets build/px3_ose.com
	mformat -i $@ -C -f 360 -v "PX3-2ND" -N "8B033602"
	$(MCOPYOPTS) mcopy -i $@ build/px3_ose.com ::px3_ose.com
	$(MCOPYOPTS) mcopy -i $@ assets/maplist.bin ::maplist.bin
	$(foreach file,$(TILES_VGA) $(TILES_CMP) $(TILES_CG2) $(TILES_CGT) $(SCREENS_VGA) $(SCREENS_CMP) $(SCREENS_CG2) $(SCREENS_CGT),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MAPS2),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(TILEDESC),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(FONTS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(SOUND),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/midi_360.img: assets
	mformat -i $@ -C -f 360 -v "PX3-MIDI" -N "8B03360A"
	$(foreach file,$(MUSIC_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/full1440.img: assets build/px3_ose.com
	mformat -i $@ -C -f 1440 -v "PX3-FULL" -N "8B031440"
	$(MCOPYOPTS) mcopy -i $@ build/px3_ose.com ::px3_ose.com
	$(MCOPYOPTS) mcopy -i $@ build/assets/manual.txt ::manual.txt
	$(MCOPYOPTS) mcopy -i $@ assets/maplist.bin ::maplist.bin
	$(foreach file,$(TILES_ALL) $(SCREENS_ALL),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_NO_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MAPS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(TILEDESC),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(FONTS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(SOUND),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

build/full1200.img: assets build/px3_ose.com
	mformat -i $@ -C -f 1200 -v "PX3-FULL" -N "8B031200"
	$(MCOPYOPTS) mcopy -i $@ build/px3_ose.com ::px3_ose.com
	$(MCOPYOPTS) mcopy -i $@ build/assets/manual.txt ::manual.txt
	$(MCOPYOPTS) mcopy -i $@ assets/maplist.bin ::maplist.bin
	$(foreach file,$(TILES_ALL) $(SCREENS_ALL),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_NO_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MAPS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(TILEDESC),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(FONTS),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(SOUND),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)
	$(foreach file,$(MUSIC_MIDI),$(MCOPYOPTS) mcopy -i $@ build/assets/$(file) ::$(file);)

.PHONY: clean dosbox_vga dosbox_cga dosbox_tandy dosbox_hercules

clean:
	rm build/map.txt
	rm build/*.img
	rm build/*.com
	rm build/assets/*.bin
	rm build/assets/*.map
	rm build/assets/*.cg2
	rm build/assets/*.cga
	rm build/assets/*.cgt
	rm build/assets/*.cmp
	rm build/assets/*.vga

dosbox_vga: px3_full
	dosbox -conf dosbox/vga.conf

dosbox_cga: px3_full
	dosbox -conf dosbox/cga.conf

dosbox_tandy: px3_full
	dosbox -conf dosbox/tandy.conf

dosbox_hercules: px3_full
	dosbox -conf dosbox/hercules.conf
