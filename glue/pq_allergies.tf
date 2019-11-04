# aws_glue_job.pq_allergies:
resource "aws_glue_job" "pq_allergies" {
connections = []
default_arguments = {
"--TempDir" = "s3://aws-glue-temporary-433146468867-eu-west-2/andyt530"
"--job-bookmark-option" = "job-bookmark-enable"
"--job-language" = "python"
}
glue_version = "1.0"
max_capacity = 10
max_retries = 0
name = "pq_allergies"
role_arn = "arn:aws:iam::433146468867:role/ht-Glue-analysis"
timeout = 2880

command {
name = "glueetl"
python_version = "3"
script_location = "s3://aws-glue-scripts-433146468867-eu-west-2/andyt530/pq_allergies"
}

execution_property {
max_concurrent_runs = 1
}
}
