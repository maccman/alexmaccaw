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