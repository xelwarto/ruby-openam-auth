# Copyright 2014 Ted Elwartowski <xelwarto.pub@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'httparty'
require 'uri/http'
require 'singleton'
require 'json'

require 'openam/auth/version'
require 'openam/auth/error'
require 'openam/auth/config'
require 'openam/auth/http'
require 'openam/auth/api'

module OpenAM
  module Auth
    class << self
      def config
        OpenAM::Auth::Config.config
      end
      
      def configure(&block)
        class_eval(&block)
      end
      
      def cookie_name
        self.config.cookie_name ||= 
          OpenAM::Auth::API.get_cookie_name
      end
      
      def verify_token(token)
        OpenAM::Auth::API.verify_token token
      end
      
      def logout(token)
        OpenAM::Auth::API.logout token
      end
    end
  end
end

# Default Configuration Setup
OpenAM::Auth.configure do
  config.url          = nil
  config.cookie_name  = nil
  
  config.timeout      = 20
  
  config.login_uri    = '/UI/Login'
  config.logout_uri   = '/UI/Logout'
  config.cookie_api   = '/identity/getCookieNameForToken'
  config.token_api    = '/identity/isTokenValid'
  config.user_api     = '/json/users?_action=idFromSession'
  config.logout_api   = '/json/sessions/?_action=logout'
end
