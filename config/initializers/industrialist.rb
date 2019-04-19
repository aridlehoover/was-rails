Industrialist.config do |config|
  config.manufacturable_paths << Rails.root.join('app', 'commands')
  config.manufacturable_paths << Rails.root.join('app', 'actors')
end
