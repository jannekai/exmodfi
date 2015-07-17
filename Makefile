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

.PHONY: all deps compile test run clean errors
