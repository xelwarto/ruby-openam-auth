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
require 'singleton'

require 'openam/auth/version'
require 'openam/auth/errors'
require 'openam/auth/config'
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
    end
  end
end

# Default Configuration Setup
OpenAM::Auth.configure do
  config.timeout = 20
end
