# aws_athena_named_query.view_patients_augmented:
resource "aws_athena_named_query" "view_patients_augmented" {
database = "ht"
description = "view patients augmented"
name = "view_patients_augmented"
query = "create view view_patients_augmented as select p.*, a.risk,a.duedate,a.deldate,a.delflag from ht_patients p, ht_augmented a where p.id=a.id"
workgroup = "primary"
}
