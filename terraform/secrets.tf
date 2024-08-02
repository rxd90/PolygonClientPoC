# Shhh... don't tell anyone! We're storing Docker Hub credentials here.
resource "aws_secretsmanager_secret" "dockerhub_credentials" {
  name = "dockerhub_credentials"
}

# The secret sauce! Adding a version to our top-secret Docker Hub credentials.
resource "aws_secretsmanager_secret_version" "dockerhub_credentials_version" {
  secret_id = aws_secretsmanager_secret.dockerhub_credentials.id

  # Putting the "secret" in Secrets Manager. Also, change the password in the console!
  secret_string = jsonencode({
    username = "ricard0"
    #password = "XXXXX" # WARNING - Manual Overwrite in console required.
    password = "dckr_pat_PM5IYQL4bBw_F4PAY78gxYFBFTo"
  })
}

# Fetching our super secret Docker Hub credentials, like a ninja in the night.
data "aws_secretsmanager_secret" "dockerhub_credentials" {
  name = "dockerhub_credentials"
}

# Bringing back the secret version, because one version is never enough.
data "aws_secretsmanager_secret_version" "dockerhub_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.dockerhub_credentials.id
}