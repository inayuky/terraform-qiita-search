require 'qiita'
require 'fileutils'
require 'pstore'

module AwsCli
  module S3
    # AWS CLIでファイルをS3にアップロード
    def self.upload(bucket_name, file_name)
      args = file_name + " s3://" + bucket_name
      system("aws s3 cp " + args)
    end

    # AWS CLIでファイルをS3からダウンロード
    def self.download(bucket_name, file_name)
      args = "s3://" + bucket_name + "/" + file_name + " ."
      system("aws s3 cp " + args)
    end

  end
end

class QiitaArticle

  def initialize(sitemap="sitemap.xml")
    @sitemap = sitemap # baseとなるsitemap名
  end

  # baseとなるsitemapをS3に作成する
  def create_base_sitemap(num_of_urls, bucket_name)
    urls = get_urls(num_of_urls, 10)
    create_sitemap(urls.reverse, @sitemap)
    AwsCli::S3.upload(bucket_name, @sitemap)
    FileUtils.rm_f(@sitemap)
  end

  # Qiitaの記事を取得
  # num_of_urlsは100単位
  # stocks以上のストック数の記事を取得する
  # 環境変数"QIITA_ACCESS_TOKEN"にQiitaのAPI keyが必要
  def get_urls(num_of_urls, stocks)
    qiita_token = ENV['QIITA_ACCESS_TOKEN']
    return "QIITA_ACCESS_TOKEN not found" unless qiita_token

    client = Qiita::Client.new(access_token: qiita_token)

    per_page = 100 # １ページ辺りの記事数(最大100)
    params = {
      per_page: per_page,
      query: "stocks:>=" + stocks.to_s # 検索条件
    }

    urls = []
    1.upto(num_of_urls / per_page) do |i|
      params[:page] = i
      items = client.list_items(params)
      items.body.each do |body|
        urls << body["url"]
      end
      sleep(3) # QiitaAPIの利用制限を考慮
    end

    puts urls
    puts urls.size

    urls
  end

  # urlsをsitemap形式にして、file_nameとして保存
  def create_sitemap(urls, file_name)
    open(file_name, "w") do |f|
      f.puts '<?xml version="1.0" encoding="UTF-8"?>'
      f.puts '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
      urls.each do |url|
        f.puts "<url>"
        f.puts "<loc>" + url + "</loc>"
        f.puts "</url>"
      end
      f.puts "</urlset>"
    end
  end

end

# debug code
# qa = QiitaArticle.new
# urls = qa.get_urls(300, 10)
# qa.create_base_sitemap(100, "sample-sitemap-for-fess")