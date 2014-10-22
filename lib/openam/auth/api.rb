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
    class API
      class << self
        def get(uri=nil)
          config = OpenAM::Auth.config
          
          url = build_api(uri)
          
          if url.nil?
            raise OpenAM::Auth::Error.new('API URL is invalid')
          else
            Timeout::timeout(config.timeout) do
              HTTParty.get(url)
            end
          end  
        end
      end
      
      private
      
      def build_api(uri=nil)
        api_url = nil
        
        raise OpenAM::Auth::Error.new('configured host is invalid') if config.host.nil?
        raise OpenAM::Auth::Error.new('configured scheme is invalid') if config.scheme.nil?
        raise OpenAM::Auth::Error.new('requested URI is invalid') if uri.nil?
        
        begin
          api_uri = URI::HTTP.new(
            config.scheme,
            nil,
            config.host,
            nil,
            uri,
            nil,
            nil
          )
        rescue
          api_uri = nil
        end
        
        api_url
      end
    end
  end
end
