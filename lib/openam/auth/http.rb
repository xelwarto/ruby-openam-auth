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
    class HTTP
      include Singleton

      def initialize
        @config = OpenAM::Auth.config
      end

      class << self
        def get(uri,*opts)
          HTTP.instance.get uri
        end

        def post(uri,*opts)
          HTTP.instance.post uri,*opts
        end
      end

      def get(uri=nil,*opts)
        Timeout::timeout(@config.timeout) do
          HttpResult.new(HTTParty.post(uri,*opts))
        end
      end

      def post(uri=nil,*opts)
        Timeout::timeout(@config.timeout) do
          HttpResult.new(HTTParty.post(uri,*opts))
        end
      end
      
      class HttpResult
        attr_reader :body, :contentType
        
        def initialize(result=nil)
          raise OpenAM::Auth::Error.new('HTTP resukts are invalid') if result.nil?
          
          if !result.headers.nil?
            if !result.headers['content-type'].nil?
              @contentType = result.headers['content-type']
            end
          end
          
          if !result.body.nil?
            @body = result.body.gsub(/[\r\n]/, "")
          end
        end
        
      end
      
    end
  end
end
