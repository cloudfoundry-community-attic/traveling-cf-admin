source "https://rubygems.org"

gem "bosh-bootstrap" # includes bosh_cli & bosh_cli_plugin_micro
gem "traveling_bosh_cli_plugin"

# patched projects to support newer gems
gem 'foodcritic', github: 'acrmp/foodcritic'
gem 'bosh_vcloud_cpi', github: 'drnic/bosh_vcloud_cpi', branch: 'nokogiri'
git 'https://github.com/drnic/bosh.git', branch: 'traveling-bosh' do
  gem 'bosh_cli_plugin_micro'
end

# explicit requirements matching to traveling-ruby native gems
gem 'nokogiri', '1.6.5'
gem 'sqlite3', '1.3.9'
gem 'yajl-ruby', '1.2.1'
gem 'thin', '1.6.3'
gem 'eventmachine', '1.0.4'

group :development do
  gem 'rake'
end
