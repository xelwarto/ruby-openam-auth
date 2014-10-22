
$:.push File.expand_path("lib", File.dirname(__FILE__))
require 'openam/auth/version'

Gem::Specification.new do |spec|
  spec.name         = OpenAM::Auth::NAME
  spec.version      = OpenAM::Auth::VERSION
  spec.summary      = 'Ruby library for the OpenAM authentication API'
  spec.description  = "Library for interacting with the OpenAM authentication API, " \
                      "including token validation, account authentication and " \
                      "authenticated account retrieval"
  spec.licenses     = ['Apache-2.0']
  spec.platform     = Gem::Platform::RUBY
  spec.authors      = ['Ted Elwartowski']
  spec.email        = ['xelwarto.pub@gmail.com']
  spec.homepage     = 'https://github.com/xelwarto/ruby-openam-auth'
  
  spec.required_ruby_version  = '>= 1.9.3'
  
  # https://github.com/jnunemaker/httparty
  spec.add_dependency 'httparty', '~> 0.13'
  
  spec.add_dependency 'json', '~> 1.8'

  files = []
  dirs = %w{lib}
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end
  
  files << "LICENSE"
  spec.files = files
  spec.require_paths << 'lib'  
end
