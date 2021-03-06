require 'susy'

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

activate :sprockets

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  activate :smusher #compresses PNG files
end
