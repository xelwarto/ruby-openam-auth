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
        def get(uri)
          HTTP.instance.get uri
        end
        
        def post(uri,*opts)
          HTTP.instance.post uri,*opts
        end
      end
      
      def get(uri=nil)
        Timeout::timeout(@config.timeout) do
          res = HTTParty.get(build_api(uri))
          if !res.nil?
            if res.body.nil?
              res.gsub(/[\r\n]/, "")
            else
              res.body.gsub(/[\r\n]/, "")
            end
          end
        end 
      end
      
      def post(uri=nil,*opts)
        Timeout::timeout(@config.timeout) do
          res = HTTParty.post(build_api(uri),*opts)
          if !res.nil?
            if res.body.nil?
              res.gsub(/[\r\n]/, "")
            else
              res.body.gsub(/[\r\n]/, "")
            end
          end
        end 
      end

      private
      
      def build_api(uri=nil)
        raise OpenAM::Auth::Error.new('configured URL is invalid') if @config.url.nil?
        raise OpenAM::Auth::Error.new('requested URI is invalid') if uri.nil?
        
        api = @config.url.clone
        api << uri
        
        p = URI::Parser.new
        p.escape(api)
      end
    end
  end
end
