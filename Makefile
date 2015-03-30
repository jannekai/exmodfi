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

prod: deps
	MIX_ENV=prod mix do deps.get, compile.protocols

# For testing running in production mode, actual launch on server is done with deployment/exmodfi.upstart.conf
prod-run:
	mkdir -p log
	MIX_ENV=prod PORT=8080 elixir --name exmodfi@127.0.0.1 -pa _build/prod/consolidated -S mix phoenix.server >> log/all.log 2>&1

.PHONY: all deps compile test run clean prod prod-run
