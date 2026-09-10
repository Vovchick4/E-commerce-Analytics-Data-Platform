Markdown
# Архітектура системи: Варіант А (GCP Datastream CDC)

Цей документ описує **Варіант А** реалізації реплікації даних у реальному часі (CDC) з транзакційних баз даних в аналітичне сховище **Google BigQuery**.

## 1. Схема архітектури (Mermaid)

```mermaid
flowchart TD
    subgraph Sources["Джерела даних (OLTP)"]
        A1[(Order DB\nPostgreSQL)]
        A2[(User DB\nPostgreSQL / MySQL)]
        A3[(Catalog DB\nMongoDB)]
    end

    subgraph Ingestion["Шар Інжестії (GCP CDC)"]
        B1[GCP Datastream]
        B2[Debezium / PubSub]
        B3[Cloud Dataflow]
    end

    subgraph Storage["Шар Зберігання та Аналітики"]
        C1[(BigQuery Raw CDC\n`raw_cdc_*`)]
        C2[(BigQuery Staging\n`stg_*`)]
    end

    %% Flow connections
    A1 -->|WAL / Logical Decoding| B1
    A2 -->|Binlog| B1
    A3 -->|Change Streams / Oplog| B2

    B1 -->|Streaming Writes| C1
    B2 --> B3
    B3 -->|Flattened Records| C1

    C1 -->|Scheduled MERGE / dbt| C2
2. Опис компонентів
Компонент	Технологія	Опис та призначення
Relational CDC	GCP Datastream	Забезпечує реплікацію змін у реальному часі без навантаження на Order DB та User DB.
Document CDC	Debezium + Dataflow	Читає Change Streams з Catalog DB (MongoDB) та розгортає (flatten) nested JSON у структурований вигляд.
Raw Layer	BigQuery (raw_cdc_*)	Append-only таблиці. Зберігають всю історію змін та CDC-метадані (_metadata_timestamp, _metadata_deleted).
Staging Layer	BigQuery (stg_*)	Актуальний дедублікований стан даних (Latest State), сформований через SQL MERGE або dbt.
3. Переваги та недоліки Варіанта А
Переваги (Pros)
•	Низька затримка (Near Real-time): Дані доступні для аналітики за лічені секунди/хвилини.
•	Мінімальне навантаження на прод: Читання відбувається через логи транзакцій (WAL / Binlog), а не прямими SQL-запитами.
•	Автоматичне масштабування: Використання бессерверних (serverless) сервісів GCP (Datastream, Dataflow, BigQuery).
Недоліки (Cons)
•	Додаткова складність: Потрібна підтримка додаткових інструментів трансформації даних (dbt, Dataflow).
•	Контроль витрат: При великих об'ємах стрімінгового інжесту в BigQuery необхідно відстежувати витрати на Streaming API.

