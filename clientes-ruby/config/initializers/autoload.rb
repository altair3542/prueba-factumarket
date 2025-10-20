Rails.application.config.eager_load_paths += [
  Rails.root.join('app/domain'),
  Rails.root.join('app/application'),
  Rails.root.join('app/infrastructure')
]
