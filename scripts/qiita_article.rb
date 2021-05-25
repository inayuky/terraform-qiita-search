require 'qiita'
require 'fileutils'

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

  def initialize(sitemap="sitemap.xml", new_sitemap="new_sitemap.xml")
    @sitemap = sitemap # baseとなるsitemap名
    @new_sitemap = new_sitemap # baseから差分として作成するsitemap名
  end

  # baseとなるsitemapをS3に作成する
  def create_base_sitemap(num_of_urls, bucket_name)
    urls = get_urls(num_of_urls, 100)
    create_sitemap(urls.reverse, @sitemap)
    AwsCli::S3.upload(bucket_name, @sitemap)
    FileUtils.rm_f(@sitemap)
  end

  # 古いsitemapと比較して新しいurlのみを別のsitemapとしてS3に作成する
  # 新しいsitemapはクロール時間を削減するために使用する
  def create_new_sitemap(num_of_urls, bucket_name)
    old_urls = get_urls_from_sitemap(bucket_name, @sitemap)
    new_urls = get_urls(num_of_urls, 10)

    # 新規urlのみを抽出してsitemapをS3に作成する
    diff_urls = new_urls - old_urls
    if diff_urls.size == 0
      puts "new url does not exist"
      return
    end
    create_sitemap(diff_urls.reverse, @new_sitemap)
    AwsCli::S3.upload(bucket_name, @new_sitemap)
    FileUtils.rm_f(@new_sitemap)

    # 既存のsitemapに新規のurlを追加する
    sum_urls = (old_urls + new_urls).uniq
    create_sitemap(sum_urls.reverse, @sitemap)
    AwsCli::S3.upload(bucket_name, @sitemap)
    FileUtils.rm_f(@sitemap)
  end

  # sitemap内からurlのみを抽出
  def get_urls_from_sitemap(bucket_name, file_name)
    AwsCli::S3.download(bucket_name, file_name)
    urls = []
    File.foreach(file_name) do |file|
      urls << file.gsub(/<loc>|<\/loc>/, "").chomp if file.include?("loc")
    end
    FileUtils.rm_f(file_name)
    urls
  end

  # Qiitaの記事を取得
  # num_of_urlsは100単位
  # stocks以上のストック数の記事を取得する
  # 環境変数"QIITA_ACCESS_TOKEN"にQiitaのAPI keyが必要
  def get_urls(num_of_urls, stocks)
    client = Qiita::Client.new

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
# qa.get_urls(300, 10)
# qa.create_base_sitemap(100, "sample-sitemap-for-fess")
# qa.create_new_sitemap(100, "sample-sitemap-for-fess")