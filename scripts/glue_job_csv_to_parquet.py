import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext

description = "Glue Job: CSV → Parquet Export – wurde erfolgreich reinitialisiert"

# Glue-Spezifische Initialisierung
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Eingabe- & Ausgabe-Pfade
input_path = "s3://dataforge-model-storage/csv/fact_appointments.csv"
output_path = "s3://dataforge-model-storage/parquet/"

# CSV-Dateien lesen
datasource = spark.read.option("header", "true").csv(input_path)

# Optional: Datentypen anpassen (hier nur beispielhaft)
# from pyspark.sql.functions import col
# datasource = datasource.withColumn("total_cost", col("total_cost").cast("double"))

# In Parquet schreiben
datasource.write.mode("overwrite").parquet(output_path)

# Job abschließen
job.commit()
