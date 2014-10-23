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

        def build(uri,*opts)
          HTTP.instance.build_url uri,*opts
        end
      end

      def get(uri=nil)
        Timeout::timeout(@config.timeout) do
          res = HTTParty.get(build_url(uri))
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
          res = HTTParty.post(build_url(uri),*opts)
          if !res.nil?
            if res.body.nil?
              res.gsub(/[\r\n]/, "")
            else
              res.body.gsub(/[\r\n]/, "")
            end
          end
        end
      end

      def build_url(uri=nil,*opts)
        raise OpenAM::Auth::Error.new('configured URL is invalid') if @config.url.nil?
        raise OpenAM::Auth::Error.new('requested URI is invalid') if uri.nil?

        api = @config.url.clone
        api << uri

        p = URI::Parser.new
        api = p.escape(api)

        if !opts.nil? && !opts.first.nil?
          if opts.first.instance_of? Hash
            params = []
            opts.first.each do |k,v|
              if !v.nil?
                p = URI::Parser.new(:RESERVED => '')
                v = p.escape(v)
                params.push "#{k}=#{v}"
              end
            end
            api << "?"
            api << params.join('&')
          end
        end

        api
      end
    end
  end
end
