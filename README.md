# Qiita Search

## Description

Qiitaの人気記事を検索するサイトである[Qiita Search](https://qiita-search.com)を構築するTerraformテンプレート。

## Features

1. 主にEC2やネットワーク系リソースを作成し、ECRに格納したイメージからFessを起動している
2. [scripts](scripts)配下にはQiitaの人気記事を抽出し、S3バケットにURLを格納するスクリプトがある
3. [.circleci/config.yml](.circleci/config.yml)でCircleCIからTerraformによる配備やスクリプト実行をするように構成している
4. 東京リージョンに作成される

## Requirement

- Terraformがインストールされていること
- AWS CLIがインストールされており、AWSリソースを作成するのに必要な権限があること

## Installation

```
$ git clone https://github.com/inayuky/terraform-qiita-search
$ cd terraform-qiita-search
$ terraform init
```

## Usage

以下で作成できるが、ドメイン名やS3のバケット名など作者のみが使用できる値が含まれるので、作者以外はそれらの値を変更しないと作成できない。

`$ terraform apply -var-file terraform.tfvars`

作成後、以下でALB関連リソースのみ削除できる。

`$ terraform destory -target=module.alb`

ALB削除後は再度applyすれば復旧する。

`$ terraform apply -var-file terraform.tfvars`

## License

MIT