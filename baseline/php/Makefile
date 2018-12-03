install:
	composer install --classmap-authoritative --no-scripts --no-dev

preview:
	php -S 127.0.0.1:8000 bref.php

deploy: install
	vendor/bin/bref deploy
