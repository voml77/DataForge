import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Initialisierung
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# S3 Input & Output-Pfade
input_path = "s3://dataforge-model-storage/structured/data.json"
output_path = "s3://dataforge-model-storage/parquet/structured/"

# Zeilenweise als Text lesen (JSONL)
lines_df = spark.read.text(input_path)

# Jede Zeile einzeln als JSON parsen
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, LongType

# Schema definieren – passend zu deinen Daten
schema = StructType([
    StructField("ID", StringType(), True),
    StructField("Timestamp", LongType(), True),
    StructField("SensorValue", DoubleType(), True),
    StructField("Status", StringType(), True)
])

json_df = lines_df.select(from_json(col("value"), schema).alias("data")).select("data.*")

# In DynamicFrame umwandeln
from awsglue.dynamicframe import DynamicFrame
dyf = DynamicFrame.fromDF(json_df, glueContext, "dyf")

# In Parquet schreiben
glueContext.write_dynamic_frame.from_options(
    frame=dyf,
    connection_type="s3",
    connection_options={"path": output_path},
    format="parquet",
    transformation_ctx="output"
)

if "job_type" in args and args["job_type"] == "rds_export":
    # CSV-Datei aus S3 lesen
    input_path = "s3://dataforge-model-storage/csv/fact_appointments.csv"
    df = spark.read.option("header", "true").option("inferSchema", "true").csv(input_path)

    # In DynamicFrame konvertieren
    dyf = DynamicFrame.fromDF(df, glueContext, "dyf")

    # In relationale Datenbank schreiben
    glueContext.write_dynamic_frame.from_options(
        frame=dyf,
        connection_type="postgresql",
        connection_options={
            "url": "jdbc:postgresql://<RDS-ENDPOINT>:5432/<DBNAME>",
            "user": "<USERNAME>",
            "password": "<PASSWORD>",
            "dbtable": "fact_appointments",
            "customJdbcDriverS3Path": "s3://<bucket>/drivers/postgresql-42.2.18.jar",
            "customJdbcDriverClassName": "org.postgresql.Driver"
        },
        transformation_ctx="rds_output"
    )

job.commit()
