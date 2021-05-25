$:.unshift File.dirname($0)
require 'qiita_article'

# コマンドライン引数
# 0: 取得する記事の数
# 1: base or new (baseがデフォルト)
# 2: バケット名
#
# 実行例)
# ruby create_sitemap.rb 100
# → 100個の記事のURLをQiitaから取得し、デフォルトバケットの中にsitemapとして保存する
#
# ruby create_sitemap.rb 1000 new sample-bucket
# → 1000個の記事のURLをQiitaから取得し、古いsitemapとの差分をsample-bucketバケットの中に新しいsitemapとして保存する

DEFAULT_NUM_OF_URLS = 100
DEFAULT_BUCKET_NAME = "inayuky-qiita-search-urls"

num_of_urls = ARGV[0] ? ARGV[0].to_i : DEFAULT_NUM_OF_URLS
bucket_name = ARGV[2] || DEFAULT_BUCKET_NAME

qa = QiitaArticle.new
if ARGV[1] == "new"
  qa.create_new_sitemap(num_of_urls, bucket_name)
else
  qa.create_base_sitemap(num_of_urls, bucket_name)
end