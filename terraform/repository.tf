resource "aws_ecr_repository" "ecr" {
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
}

resource "null_resource" "docker_packaging" {
    provisioner "local-exec" {
        command = <<EOF
        aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-central-1.amazonaws.com
        gradle build -p ecr
        docker build -t "${aws_ecr_repository.noiselesstech.repository_url}:latest" -f ecr/Dockerfile .
        docker push "${aws_ecr_repository.noiselesstech.repository_url}:latest"
        EOF
    }

    triggers = {
        "run_at" = timestamp()
    }

    depends_on = [aws_ecr_repository.noiselesstech]
}