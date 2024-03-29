################################################################################
# Generic Gemfile
# Updated according to:
#   - Michael Hartl 3-rd Edition (Listing 11.67)
#   - BKC standards (?)
#   - Heroku
# 
# 28.06.2015  ZT
# 07.01.2020  Version for Rails 6 + Webpacker + ReactJS
# 29.03.2020  'enum_help' is OFF
# 02.04.2020  Ruby 2.7.1 / Rails 6.0.2.2
# 03.07.2020  Rails 6.0.3.2
################################################################################
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'
gem 'rails', '6.0.3.2'                          # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

gem 'sqlite3'                                   # Use sqlite3    as the database for Active Record
#gem 'sqlite3', groups: [:test, :development]
#gem 'mysql2'                                   # Use mysql      as the database for Active Record
#gem 'pg'                                       # Use postgresql as the database for Active Record
#gem 'pg_search'                                # https://mkdev.me/posts/kak-delat-full-text-poisk-v-rails-pri-pomoschi-postgresql
#gem 'seed_dump'                                # https://github.com/rroblak/seed_dump

gem 'puma'                                      # Use Puma as the app server (NOT 4
# gem 'uglifier'                                  # Use Uglifier as compressor for JavaScript assets

#gem 'sass-rails', '>= 6'
gem 'sassc-rails'
gem 'webpacker'                                 # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'react-rails'   # react_component helper!   # https://rubygems.org/gems/react-rails/versions/1.7.1
                    # Do: rails generate react:install
#gem 'therubyracer', platforms: :ruby           # Call JavaScript code and manipulate JavaScript objects from Ruby.
                                                # Call Ruby code and manipulate Ruby objects from JavaScript.
gem 'haml-rails'                                # https://github.com/indirect/haml-rails
#gem 'responders'

gem 'mini_racer', platforms: :ruby              # See https://github.com/rails/execjs#readme for more supported runtimes

#gem 'coffee-rails', '~> 4.2'      stop         # Use CoffeeScript for .coffee assets and views
#gem 'jquery-rails'                stop         # Use jquery as the JavaScript library
#gem 'turbolinks'                                # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jbuilder'                                  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

#gem 'redis'                                    # Use Redis adapter to run Action Cable in production

#gem 'sdoc', group: :doc                        # bundle exec rake doc:rails generates the API under doc/api.
gem 'bcrypt'                                    # Use ActiveModel has_secure_password

#gem 'zt_admin', :github => 'zhenyat/zt_admin', :branch => 'master'

# crono for jobs
#gem 'crono'
#gem 'daemons'
#gem 'sinatra', require: nil                     # to run web-console for crono

#gem 'whenever', :require => false
#gem "simple_scheduler"

# Charts
#gem 'gon'
#gem 'fusioncharts-rails'
#gem 'chartkick'                                # NOT USED (just for reference)
#
#gem 'rest-client'                              # https://github.com/rest-client/rest-client
#gem 'devise'                                   # https://github.com/plataformatec/devise

gem 'pundit'                                    # https://github.com/elabs/pundit
#gem 'ckeditor'                                 # https://github.com/galetahub/ckeditor
#gem 'carrierwave'                              # https://github.com/carrierwaveuploader/carrierwave
gem 'mini_magick'                               # Use ActiveStorage variant https://github.com/minimagick/minimagick
# gem 'image_processing', '~> 1.2'              # Use Active Storage variant

#gem "acts_as_list"                             # https://github.com/swanandp/acts_as_list
#gem 'acts-as-taggable-on'                      # https://github.com/mbleigh/acts-as-taggable-on

gem 'bootsnap', '1.4.7', require: false         # Reduces boot times through caching; required in config/boot.rb

# MH 3-rd Edition
gem 'faker'
#gem 'fog'

#gem 'bootstrap'                                 # https://github.com/twbs/bootstrap-rubygem

#gem 'lightbox2-rails'                           # https://github.com/gavinkflam/lightbox2-rails
#gem 'simple_form'                               # https://github.com/plataformatec/simple_form
# gem 'enum_help'       Not needed for Rails 6

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw] # Byebug is a Ruby 2 debugger. Call 'byebug' anywhere in the code to stop execution and get a debugger console
                                                      # https://github.com/deivid-rodriguez/byebug
end

group :development do
  gem 'foreman'
  gem 'web-console'#, '>= 3.3.0'           # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'listen'#, '>= 3.0.5', '< 3.2'        # https://github.com/guard/listen
# gem 'solargraph'        # For VS Code    # https://github.com/rails/execjs
  #gem 'spring'                            # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring-watcher-listen', '~> 2.0.0' # Makes spring watch files using the listen gem.
end

group :test do
  #gem 'capybara', '>= 2.15'              # Adds support for Capybara system testing and selenium driver
  #gem 'selenium-webdriver'
  gem 'minitest-reporters'
  gem 'mini_backtrace'
  gem 'guard'
  gem 'guard-minitest'

  gem 'webdrivers'                  # replaced chromedriver-helper after 2019-03-31
# gem 'chromedriver-helper'         # Easy installation and use of chromedriver to run system tests with Chrome
end

# Heroku
#group :production do
#  gem 'rails_12factor'
#end

# gem 'unicorn'                                 # Use Unicorn as the app server
# gem 'capistrano-rails', group: :development   # Use Capistrano for deployment

#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]   # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
