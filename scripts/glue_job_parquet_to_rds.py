import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext

# Initialisiere Glue-Job
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Lade Parquet-Daten aus S3
input_path = "s3://dataforge-model-storage/parquet/"
parquet_df = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="parquet",
    connection_options={"paths": [input_path]},
    format_options={}
)

# Wandle zu DataFrame, falls Transformationen nötig
df = parquet_df.toDF()

# Optional: Transformationen (z. B. Spaltennamen anpassen)
# df = df.withColumnRenamed("old_col", "new_col")

# Zurück zu DynamicFrame
dynamic_frame = DynamicFrame.fromDF(df, glueContext, "dynamic_frame")

# Schreibe nach MySQL (RDS) über definierte Connection
glueContext.write_dynamic_frame.from_options(
    frame=dynamic_frame,
    connection_type="mysql",
    connection_options={
        "connectionName": "dataforge-mysql-conn",
        "database": "dataforge",
        "dbtable": "fact_appointments"
    }
)

job.commit()
