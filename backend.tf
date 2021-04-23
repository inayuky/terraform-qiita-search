terraform {
  backend "s3" {
    bucket = "inayuky-terraform-tfstate"
    key    = "terraform-qiita-serach/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
