output "sg_database_id"{
    value = aws_security_group.database.id
}

output "sg_application_id"{
    value = aws_security_group.application.id
}

output "sg_loadbalance_id"{
    value = aws_security_group.loadbalancer.id
}
