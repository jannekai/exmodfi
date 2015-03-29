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

test-release-console: release
	MIX_ENV=prod PORT=4000 rel/exmodfi/bin/exmodfi console

test-release-start:
	MIX_ENV=prod PORT=4000 rel/exmodfi/bin/exmodfi start

test-release-stop:
	MIX_ENV=prod PORT=4000 rel/exmodfi/bin/exmodfi stop

test-release-ping:
	MIX_ENV=prod PORT=4000 rel/exmodfi/bin/exmodfi ping

.PHONY: all deps compile test run clean release test-release-console test-release-start test-release-stop deploy
