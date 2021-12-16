# Development environment v3

Окружение разработки v3 предназначено для удобной локальной разработки приложений.

Для работы Окружения необходимы следующие зависимости:

- make
- docker
- docker-compose не ниже **1.12.0** версии

_make_ и _docker_ устанавливаются глобально через пакетный менеджер Вашего дистрибутива,
_docker-compose_ можно установить также глобально через пакетный менеджер, либо локально через **pip** (Python Package manager).

Пример установки зависимостей в Debian/Ubuntu-производных дистрибутивах:

```sh
$ sudo apt-get install make docker docker-compose
```

Далее необходимо склонировать Окружение разработки в любую папку, например в домашнюю:

```sh
$ git clone https://github.com/abra7134/devenv3 ~/devenv3
```

## Основные команды

Все возможные действия описаны в файле **Makefile**:

- _init_ - инициализация окружения разработки
- _build_ - сборка необходимых Docker-образов
- _up_ или _run_ или _start_ - локальный запуск Окружения Разработки

#### Инициализация окружения разработки

Перед началом работы необходимо сконфигурировать файл настроек `.env` (необходимые параметры указаны в примере `.env.example`) и создать `~/www/` папку.

Сделать это можно с помощью следующей команды:

```sh
$ make init
```

#### Сборка необходимых Docker-образов

Далее необходимо собрать локальные Docker-образы. Операция может занять некоторое время.

```sh
$ make build
```

#### Локальный запуск Окружения разработки

И, наконец, остаётся запустить Окружение разработки. Команду рекомендуется запускать в отдельном терминале, для удобного наблюдения за логами:

```sh
$ make up
```

## Схема работы с PHP-приложениями

#### Общая информация

Для разработки и тестирования веб-приложений в Окружении разработки доступны веб-сервер **nginx** и обработчики **php5.6-fpm**, **php7.1-fpm** и **php7.2-fpm** с необходимыми преднастройками (почти идентично повторяющими настройки боевых серверов).
Окружение разработки доступно под локальным доменом:

    *.localhost

Для хранения веб-приложений на этапе инициализации Окружения разработки была создана отдельная папка `~/www/` в домашней директории.

#### Структура `~/www/` папки
```
~/www/[default/]
~/www/[catchall/]
~/www/имя_проекта-1/
~/www/имя_проекта-2/
~/www/...
~/www/имя_проекта-X/
```
Папка `www/` в домашней директории предназначена для хранения веб-приложений. Имя любой папки здесь сразу отображается в имя хоста.
Т.е. для организации доступа к новому веб-приложения достаточно просто **создать папку** с
нужным названием и **скопировать** туда проект!

Проект будет сразу доступен по локальному адресу: `http://имя_проекта.localhost` (например: `http://api_client.localhost`).

`имя_проекта` может содержать буквы, цифры, знак подчеркивания и тире (в regexp нотации `[[:alnum:]_-]`).

Также существуют два специальных имени: `default` и `catchall` с нестандартным поведением:

* Приложение в папке `default` будет обрабатывать запросы, поступившие на короткий адрес (без указания имени проекта), т.е. просто на `http://localhost`;
* А приложение в папке `catchall` будет обрабатывать запросы всех **не существующих** проектов.

Поиск индексных файлов `index.htm`, `index.html`, `index.php` осуществляется в следующих папках (что найдет позднее - то и обработает):
```
~/www/имя_проекта/
~/www/имя_проекта/web/
~/www/имя_проекта/api/web/
~/www/имя_проекта/public/
```
Для добавления новых типов индексных файлов, а также папок для их поиска следует обратиться к администратору.

PS: Изменение прав доступа к файлам не требуется, т.к. все файлы хранятся и обрабатываются под личной учетной записью (!!! никаких `chmod 777` использовать не нужно - это признак дурного тона).

#### Алиасы

Окружение разработки поддерживает *алисы*, т.е. альтернативные названия проектов. Для этого достаточно создать символическую ссылку с помощью стандартной команды `ln --symbolic` (либо короткая запись `ln -s`).

Например, мы хотим, чтобы проект `http://api_client.localhost` был также доступен и как `http://ca.localhost`, то для этого необходимо cоздать ссылку `api_client` -> `ca` следующим образом:
```sh
$ cd www
$ ln -s api_client ca
```
Для правильного функционирования сайта на основе `yii-advanced` темплейта рекомендуется создать следующие символьные ссылки (предположим сам сайт у нас хранится в директории `site`):
```sh
$ cd www
$ ln -s site/backend admin
$ ln -s site/frontend catchall
$ ln -s site/landing landing
$ ln -s site/landing default
```

#### PHP

В Окружении разработки доступны **PHP5.6**, **PHP7.1** и **PHP7.2** обработчики, однако по умолчанию работает **PHP5.6** обработчик.
Чтобы проект запускался через 7ую версию необходимо в папку проекта записать пустой файл: `.profile_php7.1` или `.profile_php7.2` соответственно (обратите внимание на точку в начале).

Пример создания такого файла из командной строки:
```sh
$ cd www/имя_проекта
$ touch .profile_php7.1
```

#### XDebug

Для использования удаленной трассировки с помощью расширения **xdebug** необходимо в папку проекта записать пустой файл: `.profile_xdebug`

Наличие этого файла даст указание веб-серверу использовать `php`-обработчик с параметрами: `xdebug.remote_enable=1`, `xdebug.remote_connect_back=1`, которые разрешают удаленную трассировку, а также увеличенным максимальным временем исполнения php скрипта *до 120 секунд* (в обычном режиме *только 10 секунд*).

Если необходимо вместо *remote_connect_back* режима использовать *remote_autostart*, то можно воспользоваться переопределением в `.user.ini` файле, который необходимо создать в папке с индексным файлом (например: `web/`, `api/web/`, `public/`) со следующим содержимым:
```
xdebug.remote_connect_back=0
xdebug.remote_autostart=1
xdebug.remote_host=адрес_хоста_с_xdebug_отладчиком
xdebug.remote_port=порт_xdebug_отладчика
```
