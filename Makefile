
MAKEFILE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: run

deps:
	mix local.hex --force
	mix deps.clean --all
	mix deps.get
	mix deps.compile

compile:
	mix compile

test:
	mix test

routes: compile
	mix phoenix.routes

run: compile
	iex -S mix phoenix.server

clean:
	mix deps.clean --all
	mix clean

prod-build: deps
	mkdir -p log
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod mix local.hex --force
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod mix deps.clean --all
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod mix mix deps.get
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod mix mix deps.compile
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod mix do deps.get, compile.protocols

# For testing running in production mode, actual launch on server is done with deployment/exmodfi.upstart.conf
prod-run:
	HOME=$(MAKEFILE_DIR) MIX_ENV=prod PORT=8080 elixir --name exmodfi@127.0.0.1 -pa _build/prod/consolidated -S mix phoenix.server >> log/all.log 2>&1

.PHONY: all deps compile test run clean prod-build prod-run
