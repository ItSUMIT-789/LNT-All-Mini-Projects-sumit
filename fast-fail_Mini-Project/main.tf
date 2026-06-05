resource "local_file" "demo" {
  filename = "hello.txt"
  content  = "Hello from Terraform CI/CD Pipeline"
}
resource "local_file" "staging" {
  filename = "staging.txt"
  content  = "Staging Environment"
}