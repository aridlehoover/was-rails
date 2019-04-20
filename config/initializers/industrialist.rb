Industrialist.config do |config|
  config.manufacturable_paths << Rails.root.join('app', 'actors')
  config.manufacturable_paths << Rails.root.join('app', 'commands')
end
