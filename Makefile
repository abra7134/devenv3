init:
	echo "USER_ID=`id --user`" > .env
	echo "GROUP_ID=`id --group`" >> .env
	mkdir --parents ~/www

build:
	docker-compose build

up run start:
	docker-compose up
