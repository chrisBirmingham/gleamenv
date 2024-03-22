.PHONY: all clean

EXE=gleamenv

all: $(EXE)
	gleam run -m gleescript
	chmod +x $(EXE)

install: $(EXE)
	install $(EXE) /usr/local/bin

clean:
	gleam clean
	@rm -f $(EXE)

