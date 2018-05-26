terragrunt = {
  remote_state {
    backend = "s3"

    config {
      profile        = "default"
      region         = "eu-west-2"
      bucket         = "kshaa-concourse-tfstate"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      encrypt        = true
      dynamodb_table = "concourse-terraform-lock"
    }
  }
}