module Sinatra
  module StaticCache
    # We need to set proper caching headers on static files
    # in production, and unfortunately the only way of doing this
    # is by overriding Sinatra's static!

    def static!
      return if (public_dir = settings.public_folder).nil?
      public_dir = File.expand_path(public_dir)

      path = File.expand_path(public_dir + unescape(request.path_info))
      return unless path.start_with?(public_dir) and File.file?(path)

      env['sinatra.static_file'] = path
      expires 1.year.to_i, :public, :max_age => 31536000
      send_file path, :disposition => nil
    end
  end
end