build:
	./node_modules/.bin/coffeebar -b -o dist/js/tutorialize.js src/js/tutorialize.coffee
	./node_modules/.bin/coffeebar -b -m -o dist/js/tutorialize.min.js src/js/tutorialize.coffee
	./node_modules/.bin/node-sass --sourcemap=none src/css/tutorialize.scss dist/css/tutorialize.css
	./node_modules/.bin/node-sass --style compressed --sourcemap=none src/css/tutorialize.scss dist/css/tutorialize.min.css

.PHONY: build
