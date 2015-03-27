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

.PHONY: all deps compile test run clean
