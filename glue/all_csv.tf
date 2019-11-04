# aws_glue_crawler.all_csv:
resource "aws_glue_crawler" "all_csv" {
classifiers = []
database_name = "ht"
name = "all_csv"
role = "ht-Glue-analysis"
table_prefix = "csv_"

s3_target {
exclusions = []
path = "s3://ht-raw-csv"
}

schema_change_policy {
delete_behavior = "DEPRECATE_IN_DATABASE"
update_behavior = "UPDATE_IN_DATABASE"
}
}
