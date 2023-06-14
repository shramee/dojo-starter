build:
	docker compose exec dojoengine sozo build

build-local:
	cd ./contracts; sozo build

start:
	docker compose up

deploy:
	@SOZO_OUT="$$(docker compose exec dojoengine sozo migrate)"; echo "$$SOZO_OUT"; \
	/bin/echo $$SOZO_OUT | grep "World at address" | rev | cut -d " " -f 1 | rev >> ./deployed_worlds
	