#!/bin/bash

DZX7=z88dk-dzx7
CONV_MIDI=../MIDI-Converter/convert.sh
PX3_DDL="../Planet-X3-With-Soundtrack/Planet X3 Digital Download"
DEST=assets
DIR_6ISLAND="../6ISLAND"
CONV_GFX="../assetconv"

# Get assets from "Planet X3 Digital Download" folder

${DZX7} -f "${PX3_DDL}/DISTRO.720/A_LOSE.BIN" ${DEST}/a_lose.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MENU.BIN" ${DEST}/a_menu.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS01.BIN" ${DEST}/a_mus01.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS02.BIN" ${DEST}/a_mus02.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS03.BIN" ${DEST}/a_mus03.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS04.BIN" ${DEST}/a_mus04.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS05.BIN" ${DEST}/a_mus05.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS06.BIN" ${DEST}/a_mus06.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_MUS07.BIN" ${DEST}/a_mus07.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/A_WIN.BIN" ${DEST}/a_win.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP00.MAP" ${DEST}/map00.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP01.MAP" ${DEST}/map01.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP02.MAP" ${DEST}/map02.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP03.MAP" ${DEST}/map03.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP04.MAP" ${DEST}/map04.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP05.MAP" ${DEST}/map05.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP06.MAP" ${DEST}/map06.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP07.MAP" ${DEST}/map07.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP08.MAP" ${DEST}/map08.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP09.MAP" ${DEST}/map09.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP10.MAP" ${DEST}/map10.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP11.MAP" ${DEST}/map11.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MAP12.MAP" ${DEST}/map12.map
${DZX7} -f "${PX3_DDL}/DISTRO.720/MENU.CGA" ${DEST}/menu.cga
${DZX7} -f "${PX3_DDL}/DISTRO.720/MENU.CMP" ${DEST}/menu.cmp
${DZX7} -f "${PX3_DDL}/DISTRO.720/MENU.TDY" ${DEST}/menu.tdy
${DZX7} -f "${PX3_DDL}/DISTRO.720/MENU.VGA" ${DEST}/menu.vga
${DZX7} -f "${PX3_DDL}/DISTRO.720/SCREEN1.CGA" ${DEST}/screen1.cga
${DZX7} -f "${PX3_DDL}/DISTRO.720/SCREEN1.CMP" ${DEST}/screen1.cmp
${DZX7} -f "${PX3_DDL}/DISTRO.720/SCREEN1.TDY" ${DEST}/screen1.tdy
${DZX7} -f "${PX3_DDL}/DISTRO.720/SCREEN1.VGA" ${DEST}/screen1.vga
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_LOSE.BIN" ${DEST}/s_lose.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MENU.BIN" ${DEST}/s_menu.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS01.BIN" ${DEST}/s_mus01.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS02.BIN" ${DEST}/s_mus02.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS03.BIN" ${DEST}/s_mus03.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS04.BIN" ${DEST}/s_mus04.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS05.BIN" ${DEST}/s_mus05.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS06.BIN" ${DEST}/s_mus06.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_MUS07.BIN" ${DEST}/s_mus07.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/SOUNDS.BIN" ${DEST}/sounds.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/S_WIN.BIN" ${DEST}/s_win.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE1.CG2" ${DEST}/tile1.cg2
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE1.CGA" ${DEST}/tile1.cga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE1.CMP" ${DEST}/tile1.cmp
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE1.TDY" ${DEST}/tile1.tdy
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE1.VGA" ${DEST}/tile1.vga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE2.CG2" ${DEST}/tile2.cg2
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE2.CGA" ${DEST}/tile2.cga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE2.CMP" ${DEST}/tile2.cmp
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE2.TDY" ${DEST}/tile2.tdy
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE2.VGA" ${DEST}/tile2.vga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE3.CG2" ${DEST}/tile3.cg2
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE3.CGA" ${DEST}/tile3.cga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE3.CMP" ${DEST}/tile3.cmp
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE3.TDY" ${DEST}/tile3.tdy
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILE3.VGA" ${DEST}/tile3.vga
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILEDAT1.DAT" ${DEST}/tiledat1.dat
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILEDAT2.DAT" ${DEST}/tiledat2.dat
${DZX7} -f "${PX3_DDL}/DISTRO.720/TILEDAT3.DAT" ${DEST}/tiledat3.dat
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_LOSE.BIN" ${DEST}/t_lose.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MENU.BIN" ${DEST}/t_menu.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS01.BIN" ${DEST}/t_mus01.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS02.BIN" ${DEST}/t_mus02.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS03.BIN" ${DEST}/t_mus03.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS04.BIN" ${DEST}/t_mus04.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS05.BIN" ${DEST}/t_mus05.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS06.BIN" ${DEST}/t_mus06.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_MUS07.BIN" ${DEST}/t_mus07.bin
${DZX7} -f "${PX3_DDL}/DISTRO.720/T_WIN.BIN" ${DEST}/t_win.bin

# Pull the "SIX ISLANDS" map file from the SAVEGAME.DAT containing it.
# NOTE: You can get the ZIP file from https://www.the8bitguy.com/wp-content/uploads/2015/08/6ISLAND.zip

cp "${DIR_6ISLAND}/SAVEGAME.DAT" "${DEST}/map13.map"
truncate -c -s 32768 "${DEST}/map13.map"

# Convert MIDIs

# Roland SC-55
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/08 No More Fighting (GM).mid" "${DEST}/g_lose.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/06 Into Battle (GM).mid" "${DEST}/g_menu.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/01 Fight for the Future (GM).mid" "${DEST}/g_mus01.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 02 Apprehension (MT-32).mid" "${DEST}/g_mus02.bin" 5 # stolen from MT-32
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/04 Plan Ahead (GM).mid" "${DEST}/g_mus03.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/02 Jungle Vibes (GM).mid" "${DEST}/g_mus04.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/03 Klepackin' Heat (GM).mid" "${DEST}/g_mus05.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/05 New Lands (GM).mid" "${DEST}/g_mus06.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/09 The X2 Anthem (GM).mid" "${DEST}/g_mus07.bin" 5
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland SC-55/MIDIFILES/07 Let the Soldiers Rest (GM).mid" "${DEST}/g_win.bin" 5 # dubious

# Roland MT-32 (with extra tracks)
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 99  MT-32 SYS EX.mid" "${DEST}/m_init.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 17 No More Fighting (MT-32).mid" "${DEST}/m_lose.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 15 Into Battle (MT-32).mid" "${DEST}/m_menu.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 10 Fight for the Future (MT-32).mid" "${DEST}/m_mus01.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 02 Apprehension (MT-32).mid" "${DEST}/m_mus02.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 13 Plan Ahead (MT-32).mid" "${DEST}/m_mus03.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 11 Jungle Vibes (MT-32).mid" "${DEST}/m_mus04.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 12 Klepackin' Heat (MT-32).mid" "${DEST}/m_mus05.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 14 New Lands (MT-32).mid" "${DEST}/m_mus06.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 18 The X2 Anthem (MT-32).mid" "${DEST}/m_mus07.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 07 Valiant fighters (MT-32).mid" "${DEST}/m_win.bin" 6

${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 03 Exploring the planet (MT-32).mid" "${DEST}/m_andrs1.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 04 Building bases (MT32).mid" "${DEST}/m_andrs2.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 05 Jungle fever (MT-32).mid" "${DEST}/m_andrs3.bin" 6
${CONV_MIDI} "${PX3_DDL}/Soundtrack/Roland MT-32/MIDIFILES/PX3 06 Winter is coming (MT-32).mid" "${DEST}/m_andrs4.bin" 6

# Delete temporary .bin.csv files gererated by the MIDI converter

rm ${DEST}/*.bin.csv

# Derive text mode artwork from Tandy artwork (may take a while)

${CONV_GFX}/tdy2cgt_screen "${CONV_GFX}/mda.rom" "${DEST}/menu.tdy" "${DEST}/menu.cgt"
${CONV_GFX}/tdy2cgt_screen "${CONV_GFX}/mda.rom" "${DEST}/screen1.tdy" "${DEST}/screen1.cgt"
${CONV_GFX}/tdy2cgt_tileset "${CONV_GFX}/mda.rom" "${DEST}/tile1.tdy" "${DEST}/tile1.cgt"
${CONV_GFX}/tdy2cgt_tileset "${CONV_GFX}/mda.rom" "${DEST}/tile2.tdy" "${DEST}/tile2.cgt"
${CONV_GFX}/tdy2cgt_tileset "${CONV_GFX}/mda.rom" "${DEST}/tile3.tdy" "${DEST}/tile3.cgt"
