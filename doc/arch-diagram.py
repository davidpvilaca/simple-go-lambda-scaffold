from diagrams import Diagram, Cluster
from diagrams.aws.storage import S3
from diagrams.aws.compute import Lambda
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.compute import Server

with Diagram("Solution", show=False):

  with Cluster("Internal AWS network"):
    generate_report_lambda = Lambda("generate-report")
    s3 = S3("reports")
    unzip_lambda = Lambda("unzip")
    logs = Cloudwatch("logs")

    
    generate_report_lambda >> s3
    generate_report_lambda >> logs

    s3 >> unzip_lambda >> s3
    unzip_lambda >> logs
  
  with Cluster("External network"):
      users_api = Server("Users API")
      generate_report_lambda >> users_api
