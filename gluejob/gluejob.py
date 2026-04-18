import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job

# Capture arguments passed by Terraform/CICD
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_SOURCE_PATH', 'S3_TARGET_PATH'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 1. Read Data (Using DynamicFrame for Glue optimization)
source_df = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [args['S3_SOURCE_PATH']]},
    format="csv",
    format_options={"withHeader": True}
)

# 2. Transformation (Convert to Spark DataFrame for complex logic)
spark_df = source_df.toDF()
# Example logic: Filter out nulls or specific records
filtered_df = spark_df.filter(spark_df["id"].isNotNull())

# 3. Write Data (Writing as Parquet)
glueContext.write_dynamic_frame.from_options(
    frame=DynamicFrame.fromDF(filtered_df, glueContext, "filtered_df"),
    connection_type="s3",
    connection_options={"path": args['S3_TARGET_PATH']},
    format="parquet"
)

job.commit()
