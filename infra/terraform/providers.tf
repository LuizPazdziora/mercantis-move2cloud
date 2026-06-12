provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "edge"
  region = var.aws_region_edge
}
