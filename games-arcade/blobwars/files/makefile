PROG = blobwars
PAKNAME = blobwars.pak
DOCS = doc/*
ICONS = icons/

VERSION = 1.17
RELEASE = 1
USEPAK = 1

PREFIX=$(DESTDIR)/usr
BINDIR = $(PREFIX)/games/
DATADIR = $(PREFIX)/share/games/blobwars/
DOCDIR = $(PREFIX)/share/doc/$(PROG)/
ICONDIR = $(PREFIX)/share/icons/hicolor/
DESKTOPDIR = $(PREFIX)/share/applications/
LOCALEDIR = $(PREFIX)/share/locale/
MEDAL_SERVER_HOST = www.parallelrealities.co.uk
#MEDAL_SERVER_HOST = localhost
MEDAL_SERVER_PORT = 80

CXXFLAGS += `sdl-config --cflags` -DVERSION=$(VERSION) -DRELEASE=$(RELEASE) -DUSEPAK=$(USEPAK)
CXXFLAGS += -DPAKNAME=\"$(PAKNAME)\" -DPAKLOCATION=\"$(DATADIR)\" -DUNIX -DGAMEPLAYMANUAL=\"$(DOCDIR)index.html\" -Wall
CXXFLAGS += -DLOCALEDIR=\"$(LOCALEDIR)\" -DMEDAL_SERVER_HOST=\"$(MEDAL_SERVER_HOST)\" -DMEDAL_SERVER_PORT=$(MEDAL_SERVER_PORT)
CXXFLAGS += $(CFLAGS) -Werror
LIBS = `sdl-config --libs` -lSDL_mixer -lSDL_image -lSDL_ttf -lSDL_net -lz

OBJS += CAudio.o
OBJS += CBoss.o
OBJS += CCollision.o CCutscene.o  CConfig.o
OBJS += CData.o 
OBJS += CEffect.o CEngine.o CEntity.o 
OBJS += CFileData.o 
OBJS += CGame.o CGameData.o CGameObject.o CGraphics.o
OBJS += CHub.o 
OBJS += CKeyboard.o 
OBJS += CJoystick.o 
OBJS += CLineDef.o
OBJS += CList.o
OBJS += CMap.o CMath.o CMedalServer.o
OBJS += CObjective.o
OBJS += CPak.o CParticle.o CPersistant.o CPersistData.o
OBJS += CRadarBlip.o CReplayData.o
OBJS += CSpawnPoint.o CSprite.o CSwitch.o
OBJS += CTeleporter.o CTrain.o CTrap.o
OBJS += CWeapon.o CWidget.o

OBJS += aquaBoss.o
OBJS += bosses.o bullets.o 
OBJS += cutscene.o
OBJS += droidBoss.o 
OBJS += effects.o enemies.o entities.o explosions.o 
OBJS += finalBattle.o 
OBJS += galdov.o game.o graphics.o 
OBJS += hub.o 
OBJS += info.o init.o intro.o items.o 
OBJS += lineDefs.o loadSave.o
OBJS += map.o mapData.o mias.o mission.o
OBJS += objectives.o obstacles.o options.o
OBJS += particles.o player.o 
OBJS += resources.o 
OBJS += spawnPoints.o switches.o 
OBJS += tankBoss.o teleporters.o title.o trains.o traps.o triggers.o 
OBJS += weapons.o widgets.o

GAMEOBJS = $(OBJS) main.o
MAPOBJS = $(OBJS) mapEditor.o
PAKOBJS = CFileData.o pak.o

LOCALE_MO = $(patsubst %.po,%.mo,$(wildcard locale/*.po))

# top-level rule to create the program.
all: $(PROG) pak $(LOCALE_MO)

# compiling other source files.
%.o: src/%.cpp src/%.h src/defs.h src/defines.h src/headers.h
	$(CXX) $(CXXFLAGS) -c $<

# linking the program.
$(PROG): $(GAMEOBJS)
	$(CXX) $(LIBS) $(GAMEOBJS) -o $(PROG)
	
pak: $(PAKOBJS)
	$(CXX) $(LIBS) $(PAKOBJS) -o pak

%.mo: %.po
	msgfmt -c -o $@ $<

mapeditor: $(MAPOBJS)
	$(CXX) $(LIBS) $(MAPOBJS) -o mapeditor

# cleaning everything that can be automatically recreated with "make".
clean:
	$(RM) $(GAMEOBJS) mapEditor.o pak.o $(PROG) $(PAKNAME) pak mapeditor $(LOCALE_MO)
	
buildpak:
	./pak data gfx music sound $(PAKNAME)

install:

	./pak data gfx music sound $(PAKNAME)

	mkdir -p $(BINDIR)
	mkdir -p $(DATADIR)
	mkdir -p $(DOCDIR)
	mkdir -p $(ICONDIR)16x16/apps
	mkdir -p $(ICONDIR)32x32/apps
	mkdir -p $(ICONDIR)64x64/apps
	mkdir -p $(DESKTOPDIR)

	install -o root -g games -m 755 $(PROG) $(BINDIR)$(PROG)
	install -o root -g games -m 644 $(PAKNAME) $(DATADIR)$(PAKNAME)
	install -o root -g games -m 644 $(DOCS) $(DOCDIR)
	cp $(ICONS)$(PROG).png $(ICONDIR)32x32/apps/
	cp $(ICONS)$(PROG)-mini.png $(ICONDIR)16x16/apps/$(PROG).png
	cp $(ICONS)$(PROG)-large.png $(ICONDIR)64x64/apps/$(PROG).png
	cp $(ICONS)$(PROG).desktop $(DESKTOPDIR)

	@for f in $(LOCALE_MO); do \
		lang=`echo $$f | sed -e 's/^locale\///;s/\.mo$$//'`; \
		mkdir -p $(LOCALEDIR)$$lang/LC_MESSAGES; \
		echo "cp $$f $(LOCALEDIR)$$lang/LC_MESSAGES/$(PROG).mo"; \
		cp $$f $(LOCALEDIR)$$lang/LC_MESSAGES/$(PROG).mo; \
	done

uninstall:
	$(RM) $(BINDIR)$(PROG)
	$(RM) $(DATADIR)$(PAKNAME)
	$(RM) -r $(DOCDIR)
	$(RM) $(ICONDIR)$(ICONS)$(PROG).png
	$(RM) $(ICONDIR)16x16/apps/$(PROG).png
	$(RM) $(ICONDIR)32x32/apps/$(PROG).png
	$(RM) $(ICONDIR)64x64/apps/$(PROG).png
	$(RM) $(DESKTOPDIR)$(PROG).desktop

	@for f in $(LOCALE_MO); do \
		lang=`echo $$f | sed -e 's/^locale\///;s/\.mo$$//'`; \
		echo "$(RM) $(LOCALEDIR)$$lang/LC_MESSAGES/$(PROG).mo"; \
		$(RM) $(LOCALEDIR)$$lang/LC_MESSAGES/$(PROG).mo; \
	done

