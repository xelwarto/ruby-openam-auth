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

module OpenAM
  module Auth
    class Authenticator
      class << self
        def get_cookie_name
          config = OpenAM::Auth.config
          
          name = OpenAM::Auth::API.get(config.cookie_api)
          if name.nil?
            raise OpenAM::Auth::Error.new('returned cookie name is invalid')
          else
            name.gsub!(/[\r\n]/, "")
            name.gsub!(/\Astring\=/, "")
          end
          
          name
        end
      end
    end
  end
end
