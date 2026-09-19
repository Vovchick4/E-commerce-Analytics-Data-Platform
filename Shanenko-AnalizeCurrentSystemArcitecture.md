Markdown
# Архітектура системи: (GCP Datastream CDC)

Реалізація реплікації даних у реальному часі (CDC) з транзакційних баз даних в аналітичне сховище **Google BigQuery**.

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

