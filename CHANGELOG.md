# Development environment 3 (devenv3)

## История изменений

### v0.2 ()

- `Makefile` заменен на BASH-скрипт `devenv3.bash` с улучшенной архитектурой
- **nginx**: Добавлен аргумент `NGINX_VERSION` в `Dockerfile`
- Добавлен `CHANGELOG.md`

### v0.1 (2019/02/05)

- Добавлен `README.md`
- Уменьшен размер `opcache` для `PHP`-обработчиков с 512 до 256 Мбайт
- Добавлена поддержка `.profile-xdebug` и `php-fpm-71`, `php-fpm-72` обработчиков
- Папка приложений перемещена из `/opt/www` в `~/www`
- Первая внутренняя версия
