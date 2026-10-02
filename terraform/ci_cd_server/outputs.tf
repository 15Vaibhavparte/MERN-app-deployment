# outputs.tf

output "jenkins_url" {
  description = "The URL to access the Jenkins Web UI"
  value       = "http://${module.ci_cd_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "The URL to access the SonarQube Web UI"
  value       = "http://${module.ci_cd_server.public_ip}:9000"
}

output "cicd_server_public_ip" {
  description = "The public IP of the CI/CD Server"
  value       = module.ci_cd_server.public_ip
}

output "cicd_server_instance_id" {
  description = "The EC2 Instance ID of the CI/CD Server"
  value       = module.ci_cd_server.instance_id
}

output "ssh_command" {
  description = "Command to SSH into the CI/CD server"
  value       = "ssh ubuntu@${module.ci_cd_server.public_ip}"
}