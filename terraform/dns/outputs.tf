output "zone_id" {
  value = aws_route53_zone.k8s_subdomain.zone_id
}

output "name_servers" {
  value = aws_route53_zone.k8s_subdomain.name_servers
}
