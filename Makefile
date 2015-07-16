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

prod-build:
	mkdir -p log
	MIX_ENV=prod mix local.hex --force
	MIX_ENV=prod mix deps.clean --all
	MIX_ENV=prod mix deps.get
	MIX_ENV=prod mix deps.compile
	MIX_ENV=prod mix do deps.get, compile.protocols

# For testing running in production mode, actual launch on server is done with deployment/exmodfi.upstart.conf
prod-run:
	MIX_ENV=prod PORT=8080 iex --name exmodfi@127.0.0.1 -S mix phoenix.server

.PHONY: all deps compile test run clean prod-build prod-run
