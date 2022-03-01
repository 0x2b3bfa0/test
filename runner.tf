terraform {
  required_providers {
    iterative = {
      source = "iterative/iterative",
    }
  }
}

provider "iterative" {}

variable "name" {
  default = "runner1"
}

variable "parallelism" {
  default = 1
}

resource "iterative_task" "runners" {
  cloud       = "aws"
  name        = var.name
  parallelism = var.parallelism
  directory   = "."

  envir onment = {
    "CML_*" = "",
    "GITHUB_*" = "",
    "GITLAB_*" = "",
    "BITBUCKET_*" = "",
    "REPO_TOKEN" = "",
  }

  script = <<-END
    #!/bin/bash
    export HOME=/root
    
    curl --silent https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz |
    tar --extract --strip-components=1 --directory=/usr/bin
    dockerd &
    
    curl --silent --location https://deb.nodesource.com/setup_14.x | bash
    apt update
    apt install --yes build-essential git nodejs
    npm install --global --unsafe @dvcorg/cml

    cml runner
  END
}
