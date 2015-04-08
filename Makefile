all: frontend

database:
	./install.py

frontend:
	cd frontend; npm install; bower install; grunt build
	if [ -d frontend/dist ]; then if [ -d public ]; then rm -rf public; fi; cp -r frontend/dist public; fi

clean:
	cd frontend; grunt clean
	rm -rf public


.PHONY: frontend database
