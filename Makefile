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
	mix phoenix.server

clean:
	mix deps.clean --all
	mix clean

release:
	MIX_ENV=prod mix release

release-console: release
	MIX_ENV=prod PORT=8888 rel/exmodfi/bin/exmodfi console

release-start:
	MIX_ENV=prod PORT=8888 rel/exmodfi/bin/exmodfi start

release-stop:
	MIX_ENV=prod PORT=8888 rel/exmodfi/bin/exmodfi stop

release-ping:
	MIX_ENV=prod PORT=8888 rel/exmodfi/bin/exmodfi ping


.PHONY: all deps compile test run clean
