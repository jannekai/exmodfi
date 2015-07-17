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

# Dev environment for testing error pages
errors:
	MIX_ENV=errors mix compile
	MIX_ENV=errors iex -S mix phoenix.server


prod-build:
	MIX_ENV=prod mix local.hex --force
	MIX_ENV=prod mix deps.clean --all
	MIX_ENV=prod mix deps.get
	MIX_ENV=prod mix deps.compile

# For testing running in production mode, actual launch is done by the upstart
# task /etc/init/exmodfi.conf
prod-test:
	MIX_ENV=prod PORT=8080 iex --name exmodfi-prod-test@127.0.0.1 -S mix phoenix.server

.PHONY: all deps compile test run clean errors prod-build prod-run
