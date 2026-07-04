resource "aws_route53_zone" "k8s_subdomain" {
  name = "k8s.nitsora.com"

  tags = {
    Name = "devops-pipeline-k8s-subdomain"
  }
}
