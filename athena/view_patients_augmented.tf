# aws_athena_named_query.view_:
resource "aws_athena_named_query" "view_test2" {
database = "ht"
description = "view test2"
name = "view_test2"
query = "create view view_test2 asnselect p.*, a.risk,a.duedate,a.deldate,a.delflagnfrom ht_patients p, ht_augmented a nwhere p.id=a.id"
workgroup = "primary"
}
