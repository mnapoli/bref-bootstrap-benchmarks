install:
	composer install --classmap-authoritative --no-scripts --no-dev
	APP_ENV=prod php bin/console cache:clear --no-debug --no-warmup
	APP_ENV=prod php bin/console cache:warmup

preview:
	php -S 127.0.0.1:8000 bref.php

deploy: install
	vendor/bin/bref deploy
