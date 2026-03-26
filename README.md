# Лабораторная работа 1

## Состав решения
- `mock_data/` — 10 исходных CSV-файлов
- `sql/01_create_mock_data.sql` — создание сырой таблицы `mock_data`
- `sql/02_create_dimensions_and_fact.sql` — создание таблиц измерений и фактов
- `sql/03_fill_dimensions.sql` — заполнение таблиц измерений
- `sql/04_fill_fact.sql` — заполнение таблицы фактов
- `sql/05_checks.sql` — проверки результата
- `initdb/00_init_all.sql` — автоматическая инициализация БД при первом запуске Docker
- `docker-compose.yml` — запуск PostgreSQL в Docker

## Автоматический запуск PostgreSQL и загрузка данных
```bash
docker compose up -d
```

После **первого** запуска контейнер автоматически:
1. создаёт таблицу `mock_data`;
2. загружает все 10 CSV-файлов;
3. создаёт таблицы измерений и фактов;
4. заполняет `dim_*` и `fact_sales`.

## Важно
Скрипты из `docker-entrypoint-initdb.d` выполняются **только при первой инициализации** пустого тома PostgreSQL.
Если нужно запустить автоматическую загрузку заново, удали том данных и подними контейнер ещё раз:

```bash
docker compose down -v
docker compose up -d
```

## Параметры подключения в DBeaver
- Host: `localhost`
- Port: `5432`
- Database: `labdb`
- User: `postgres`
- Password: `postgres`

## Порядок работы
### Вариант 1 — полностью автоматически
1. Выполнить `docker compose up -d`.
2. Подключиться к БД через DBeaver.
3. При необходимости выполнить `sql/05_checks.sql` для проверки результата.

### Вариант 2 — вручную по шагам
1. Запустить PostgreSQL через Docker.
2. В DBeaver выполнить `sql/01_create_mock_data.sql`.
3. Импортировать все 10 CSV-файлов в таблицу `mock_data`.
4. Выполнить `sql/02_create_dimensions_and_fact.sql`.
5. Выполнить `sql/03_fill_dimensions.sql`.
6. Выполнить `sql/04_fill_fact.sql`.
7. Выполнить `sql/05_checks.sql`.

## Проверка
Ожидается, что:
- в `mock_data` будет 10000 строк;
- в `fact_sales` будет 10000 строк;
- суммы `raw_total` и `fact_total` совпадут.

## Примечание
Для устранения дублей таблицы `dim_customer`, `dim_seller` и `dim_product` заполняются через `GROUP BY`, чтобы одному исходному идентификатору соответствовала одна строка в измерении.
