require 'rubygems'
require 'bundler'

Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'stylus/sprockets'
require 'sprockets/cache/memcache_store'
require 'sinatra'
require 'sinatra/static_cache'
require 'rss'

configure do
  enable :protection
  set :erb, escape_html: true
end

configure do
  set :cache, Dalli::Client.new
  set :assets, Sprockets::Environment.new(settings.root)

  settings.assets.append_path('assets/javascripts')
  settings.assets.append_path('assets/stylesheets')
  settings.assets.append_path('assets/images')
  settings.assets.append_path('vendor/assets/javascripts')

  Stylus.setup(settings.assets)
end

configure :development do
  settings.assets.cache = Sprockets::Cache::FileStore.new('./tmp')
end

configure :production do
  settings.assets.cache          = Sprockets::Cache::MemcacheStore.new
  settings.assets.js_compressor  = Closure::Compiler.new
  settings.assets.css_compressor = YUI::CssCompressor.new
end

helpers do
  def asset_path(name)
    asset = settings.assets[name]
    raise UnknownAsset, "Unknown asset: #{name}" unless asset
    "/assets/#{asset.digest_path}"
  end

  def cached_posts
    settings.cache.get :posts
  end
end

get '/assets/*' do
  env['PATH_INFO'].sub!(%r{^/assets}, '')
  settings.assets.call(env)
end

get '/' do
  @posts = cached_posts
  erb :index
end

# Redirect all the old routes

%w{
  /posts/how_to_travel_around_the_world
  /posts/traveling_writing_programming
  /posts/async_ui
  /posts/node_jquery_xml_parsing
  /posts/rails_js_packaging
  /posts/book
  /posts/cambodia
  /posts/thailand
  /posts/on_education
  /posts/singapore_malaysia
  /posts/lrug_podcast
  /posts/hong_kong
  /posts/south_africa
  /posts/growl
  /posts/crowdsourcing_book
  /posts/holla
  /posts/hello
}.each do |url|
  get(url) do
    redirect "http://old.alexmaccaw.com/#{url}", 303
  end
end

get '/', :host => 'alexmaccaw.co.uk' do
  redirect 'http://alexmaccaw.com'
end
