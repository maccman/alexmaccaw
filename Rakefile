task :app do
  require './app'
end

namespace :assets do
  desc 'Precompile assets'
  task :precompile => :app do
    assets = settings.assets
    target = Pathname(settings.root) + 'public/assets'

    assets.each_logical_path do |logical_path|
      if asset = assets.find_asset(logical_path)
        filename = target.join(asset.digest_path)
        FileUtils.mkpath(filename.dirname)
        asset.write_to(filename)
      end
    end
  end
end

namespace :posts do
  def unescape_entities(entities)
    entities.gsub('&amp;', '&')
  end

  def fetch_posts
    page  = 1
    items = []

    loop do
      resp = Nestful.get('https://blog.alexmaccaw.com/feed?page=%s' % page)
      feed = RSS::Parser.parse(resp.body)
      break unless feed && feed.items.any?

      items += feed.items.map {|e|
        {title: unescape_entities(e.title.content), url: e.link.href}
      }
      page += 1
    end

    items
  end

  desc 'Cache'
  task :cache => :app do
    settings.cache.set(:posts, fetch_posts)
  end
end
