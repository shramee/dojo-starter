build:
	cd ./contracts; sozo build

start:
	docker compose up

deploy:
	docker compose exec dojoengine sozo migrate