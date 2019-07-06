# Development environment 3 (devenv3)

Окружение разработки 3 предназначено для удобной локальной разработки приложений.

Для работы Окружения необходимы следующие зависимости:

- bash
- docker
- docker-compose не ниже **1.12.0** версии

_bash_ и _docker_ устанавливаются глобально через пакетный менеджер Вашего дистрибутива,
_docker-compose_ можно установить также глобально через пакетный менеджер,
либо локально через **pip** (Python Package manager).

Пример установки зависимостей в Debian/Ubuntu-производных дистрибутивах:

```sh
$ sudo apt-get install bash docker docker-compose
```

Далее необходимо склонировать Окружение разработки в любую папку, например в домашнюю:

```sh
$ git clone https://github.com/abra7134/devenv3 ~/devenv3
```

## Основные команды

Для управления Окружением разработки подготовлен специальный **BASH**-скрипт `devenv3.bash`.
Скрипт поддерживает следующие команды:

- _build_ - сборка необходимых Docker-образов
- _down_ - удаление контейнеров Окружения Разработки (необходимо при обновлениях)
- _help_ - помощник по использованию скрипта
- _ls_ - вывод списка всех приложений с указанием используемой версии **PHP**-интерпретатора,
выбранного индексного файла, а также выбранной **GIT**-ветки или **Mercurial**-ветки
- _init_ - первоначальная инициализация Окружения Разработки (можно запускать несколько раз)
- _rm_ - удаление приложений или их алиасов
- _run_ - запуск команды внутри Окружения Разработки (например: `composer`, `php yii`, `php artisan` и т.д.)
- _run_at_ - запуск команды в указанном приложении внутри Окружения Разработки (удобно для документации)
- _set_at_ - управление различными параметрами работы приложения
(установка версии **PHP**, использование XDebug расширения, добавление алиаса)
- _up_ - локальный запуск Окружения Разработки с предварительным запуском _down_ команды

#### Инициализация окружения разработки

Перед началом работы необходимо проинициалировать окружение, запустив скрипт:

```sh
$ cd ~/devenv3  # указывается путь куда было склонировано Окружение разработки
$ bash devenv3.bash init
```

Инициализация выполнит:

- конфигурацию файла настроек `.env`;
- создаст `~/www/` папку при необходимости;
- добавит алиасы скрипта в `.bashrc` и `.zshrc` файлы.

После этого необходимо запустить новую консоль и скрипт будет доступен по следующими коротким именам:
```sh
$ de3
$ denv3
$ devenv3
```

#### Сборка необходимых `Docker`-образов

Далее необходимо собрать локальные `Docker`-образы. Операция может занять некоторое время.
```sh
$ de3 build
```

#### Локальный запуск Окружения разработки

И, наконец, остаётся запустить Окружение разработки. Команду рекомендуется запускать в отдельном терминале,
для удобного наблюдения за логами:
```sh
$ de3 up
```

## Схема работы с PHP-приложениями

#### Общая информация

Для разработки и тестирования веб-приложений в Окружении разработки доступны веб-сервер **nginx** и обработчики
**php5.6-fpm**, **php7.1-fpm** и **php7.2-fpm** с необходимыми преднастройками (почти идентично повторяющими
настройки боевых серверов). Окружение разработки доступно под локальным доменом:

    *.localhost

Для хранения веб-приложений на этапе инициализации Окружения разработки была создана отдельная
папка `~/www/` в домашней директории.

#### Структура `~/www/` папки
```
~/www/[default/]
~/www/[catchall/]
~/www/имя_приложения-1/
~/www/имя_приложения-2/
~/www/...
~/www/имя_приложения-X/
```
Папка `www/` в домашней директории предназначена для хранения веб-приложений.
Имя любой папки здесь сразу отображается в имя хоста.
Т.е. для организации доступа к новому веб-приложению достаточно просто **создать папку** с нужным названием
и **скопировать** туда приложение!

Приложение будет сразу доступно по локальному адресу: `http://имя_приложения.localhost`
(например: `http://api_client.localhost`).

`имя_приложения` может содержать буквы, цифры, тире и знак подчеркивания (в regexp нотации `[[:alnum:]_-]`).

Также существуют два специальных имени: `default` и `catchall` с нестандартным поведением:

* Приложение в папке `default` будет обрабатывать запросы, поступившие на короткий адрес
(без указания имени приложения), т.е. просто на `http://localhost`;
* А приложение в папке `catchall` будет обрабатывать запросы всех **не существующих** приложений.

Поиск индексных файлов `index.htm`, `index.html`, `index.php` осуществляется в следующих папках
(что найдет позднее - то и обработает):
```
~/www/имя_приложения/
~/www/имя_приложения/web/
~/www/имя_приложения/api/web/
~/www/имя_приложения/public/
```
Для добавления новых типов индексных файлов, а также папок для их поиска следует обратиться к администратору.

PS: Изменение прав доступа к файлам не требуется, т.к. все файлы хранятся и обрабатываются под личной учетной записью
(!!! никаких `chmod 777` использовать не нужно - это признак дурного тона).

#### Алиасы

Окружение разработки поддерживает *алисы*, т.е. альтернативные названия приложений.
Для этого достаточно создать символическую ссылку. Сделать это можно с помощью команды `de3 set_at`:

Например, мы хотим, чтобы приложение `http://api_client.localhost` было также доступно и как `http://ca.localhost`:
```sh
$ de3 set_at api_client alias ca
```

Для правильного функционирования сайта на основе `yii-advanced` темплейта рекомендуется создать следующие алиасы
(предположим он располагается в папке `site`):
```sh
$ de3 set_at site/backend  alias admin
$ de3 set_at site/frontend alias catchall
$ de3 set_at site/landing  alias landing
$ de3 set_at site/landing  alias default
```

#### PHP

В Окружении разработки доступны **5.6**, **7.1** и **7.2** версии **PHP**-интерпретатора,
однако по умолчанию будет использоваться **5.6** версия.
Для указания необходимой версии для конкретного приложения достаточно воспользоваться той же командой `de3 set_at`:
```sh
$ de3 set_at имя_приложения php 5.6
$ de3 set_at имя_приложения php 7.1
```

Команда запишет специальную метку в папку приложения
(а именно пустые файлы `.profile_php7.1` или `.profile_php7.2` (обратите внимание на точку в начале).

#### XDebug

Для включения/отключения удаленной трассировки с помощью **PHP**-расширения **xdebug** можно также воспользоваться
командой `de3 set_at`, которая запишет или удалит специальный пустой файл `.profile_xdebug` в папке приложения.

Наличие этого файла даст указание веб-серверу использовать **PHP**-интерпретатор с параметрами:
`xdebug.remote_enable=1`, `xdebug.remote_connect_back=1`, которые разрешают удаленную трассировку,
а также увеличенным максимальным временем исполнения **PHP**-скрипта *до 120 секунд* (в обычном режиме *только 10 секунд*).

Пример использования:
```sh
$ de3 set_at имя_приложения xdebug on
$ de3 set_at имя_приложения xdebug off
```

Если необходимо вместо **remote_connect_back** режима использовать **remote_autostart**,
то можно воспользоваться переопределением в `.user.ini` файле,
который необходимо создать в папке с индексным файлом
(конкретное расположение индексного файла можно узнать запустив команду Окружения разработки `ls`)
со следующим содержимым:
```ini
xdebug.remote_connect_back=0
xdebug.remote_autostart=1
xdebug.remote_host=адрес_хоста_с_xdebug_отладчиком
xdebug.remote_port=порт_xdebug_отладчика
```

#### HTTP-заголовки

В большинстве случаев на боевых серверах установлены пограничные балансировщики (в том числе и
**SSL**-терминаторы), которые запрос из Интернета траслируют уже во внутреннюю сеть приложения (кластера).
Тем самым **PHP**-переменная `REMOTE_ADDR` будет содержать в себе не **IP**-адрес клиента, который послал
запрос, а **IP**-адрес конкретного балансировщика. Оригинальный же **IP**-адрес будет записан балансировщиком
в **HTTP**-заголовок `X-Forwarded-For` (или `X-Real-Ip`).

В Окружении разработки балансировщик отсутствует.
Поэтому для удобства разработки этот заголовок устанавливается в принудительном порядке и в большинстве
случаев будет совпадать с **PHP**-переменной `REMOTE_ADDR`.

#### Вывод списка всех PHP-приложений

С помощью команды `de3 ls` можно посмотреть список всех установленных **PHP**-приложений,
а также получить дополнительную информацию о версии **PHP**-интерпретатора, выбранном индексном файле,
а также наименовании текущей **GIT**-ветки или **Mercurial**-ветки.

Колонка `TP` указывает **тип** приложения:
`->` означает алиас, `==` означает прямое отображение имени приложения в имя папки.

```sh
$ de3 ls
...
NAME          URL                          TP HOME               INDEX FILE           PHP         BRANCH
api-1         http://api-1.localhost/      == api-1/             index.php            7.1         -
admin         http://admin.localhost/      -> site/backend/      web/index.php        7.2         hg:default
bad+name      (WRONG NAME)                 == bad+name/          (NOT FOUND)          5.6         -
catchall      http://*.localhost/          -> site/frontend/     web/index.php        7.2+xdebug  hg:default
default       http://localhost/            -> site/landing/      web/index.php        5.6         hg:default
test          http://test.localhost/       == test/              api/web/index.php    7.1         git:release-1.57
test2         http://test2.localhost/      -> test/              api/web/index.php    7.1         git:release-1.57
test3         http://test3.localhost/         (OUTSIDE)          -                    -           -
test4         http://test4.localhost/         (MISSING)          -                    -           -
site          http://site.localhost/       == site/              (NOT FOUND)          5.6         hg:default
```

#### Доступ к консоли

Для запуска команды внутри Окружения разработки (например: `php yii`, `php artisan`, `composer`) существуют
команды `de3 run` и `de3 run_at`, которые запустят указанную команду под правильной версией **PHP**-интерпретатора
(версия может быть выбрана для каждого приложения индивидуально с помощью команды `de3 set_at`).

Разница их в том, что для команды `de3 run_at` требуется явно указать имя приложения,
в котором необходимо запустить команду, что очень удобно для документации
(т.к. команду можно запускать из любого местоположения),
в то время как для работы команды `de3 run` необходимо предварительно перейти в каталог c нужным приложением.

Например:
```sh
$ cd www/имя_приложения
$ de3 run php yii
$ de3 run composer
```

Либо аналогичный вариант с **run_at**:
```sh
$ de3 run_at имя_приложения php yii
$ de3 run_at имя_приложения composer
```

#### Syslog

Все **Syslog** сообщения из Окружения разработки пересылаются на машину разработчика.
Поэтому доступ к ним осуществляется таким же образом, каким разработчик читает **Syslog**-сообщения на своем компьютере.

Большинство современных **Linux**-дистрибутивов поставляются с **Systemd**, у которого все сообщения
записываются в свой журнал. Доступ к этому журналу осуществляется через команду **journalctl**.
Рассмотрим на примерах:
```sh
$ journalctl                                                     # По умолчанию показывается журнал текущего пользователя и курсор находится в начале
$ journalctl -e                                                  # Показать журнал текущего пользователя, но переместить курсор сразу в конец
$ journalctl -f                                                  # Показывать журнал в режиме реального времени
$ journalctl -F SYSLOG_IDENTIFIER                                # Показать все доступные значения параметра SYSLOG_IDENTIFIER
$ journalctl SYSLOG_IDENTIFIER=app-3.8.0                         # Показать записи только удовлетворяющие условию, а именно только с указанным идентификатором
$ journalctl -f SYSLOG_IDENTIFIER=app-3.8.0                      # Показать записи в режиме реального времени и только удовлетворяющие условию
$ journalctl PRIORITY=3                                          # Показать записи с высоким приоритетом (эти сообщения journaltctl по умолчанию раскрашивает в красный цвет)
$ journalctl PRIORITY=3 SYSLOG_IDENTIFIER=app-3.8.0              # Условия можно комбинировать по принципу И
```
