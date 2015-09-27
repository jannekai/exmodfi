all: run

hex:
	@mix do local.hex --force

rebar:
	@mix do local.rebar --force

node:
	@npm prune
	@npm install
	@npm update

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
	mix deps.clean --all
	mix clean

prod:
	@node node_modules/brunch/bin/brunch build --production
	@MIX_ENV=prod mix phoenix.digest
	@MIX_ENV=prod mix compile

prod-run:
	MIX_ENV=prod PORT=8080 LANG=en_US.UTF-8 mix phoenix.server

# Dev environment for testing error pages
errors:
	MIX_ENV=errors mix compile
	MIX_ENV=errors iex -S mix phoenix.server

.PHONY: all hex rebar node deps compile test run clean prod prod-run errors
