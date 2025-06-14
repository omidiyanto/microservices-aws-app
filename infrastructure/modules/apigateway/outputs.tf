output "api_endpoint" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.mino_api.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.mino_api.root_resource_id
} 