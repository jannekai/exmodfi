all: run

hex:
	@mix do local.hex --force

rebar:
	@mix do local.rebar --force

node:
	@npm install

deps: hex rebar node
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
	@rm -rf node_modules/*
	mix deps.clean --all
	mix clean

prod:
	MIX_ENV=prod mix compile

prod-run:
	MIX_ENV=prod PORT=8080 LANG=en_US.UTF-8 mix phoenix.server

# Dev environment for testing error pages
errors:
	MIX_ENV=errors mix compile
	MIX_ENV=errors iex -S mix phoenix.server

.PHONY: all hex rebar node deps compile test run clean errors
