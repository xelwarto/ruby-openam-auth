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

      def initialize
        @config       = OpenAM::Auth.config
        @cookie_name  = nil
      end

      def cookie_name
        @cookie_name ||= get_cookie_name
      end

      # method: logout
      #
      # JSON Result Examples:
      # { :result => "Successfully logged out" }
      def logout(token=nil)
        raise OpenAM::Auth::Error.new('token value is invalid') if token.nil?
        c_name = cookie_name

        res = OpenAM::Auth::HTTP.post(
          build_api(
            @config.logout_api,
            '_action' => 'logout'
          ),
          headers: {
            c_name => token,
            'Content-Type' => 'application/json'
          }
        )
        
        if res.body.nil? || res.contentType.nil?
          raise OpenAM::Auth::Error.new('logout request results invalid')
        else
          if res.contentType =~ /\Aapplication\/json/
            JsonResult.new res.body
          end
        end
        
      end
      
      # method: login
      #
      # JSON Result Examples:
      # { :errorMessage => "User Account Locked" }
      # { :tokenId => "TOKEN", :successUrl => "https://www.myunfpa.org/" }
      # { :errorMessage => "Authentication Error!!" }
      def login(username=nil,password=nil)
        raise OpenAM::Auth::Error.new('login username is invalid') if username.nil?
        raise OpenAM::Auth::Error.new('login password is invalid') if password.nil?
        
        res = OpenAM::Auth::HTTP.post(
          build_api(
            @config.login_api,
            realm: @config.realm
          ),
          headers: {
            'X-OpenAM-Username' => username,
            'X-OpenAM-Password' => password,
            'Content-Type' => 'application/json'
          }
        )
        
        if res.body.nil? || res.contentType.nil?
          raise OpenAM::Auth::Error.new('login request results invalid')
        else
          if res.contentType =~ /\Aapplication\/json/
            JsonResult.new res.body
          end
        end
      end

      # method: verify_token
      #
      def verify_token(token=nil)
        raise OpenAM::Auth::Error.new('token value is invalid') if token.nil?
        
        res = OpenAM::Auth::HTTP.post(
          build_api(@config.token_api),
          body: {
            'tokenid' => token
          }
        )
        
        if res.body.nil? || res.contentType.nil?
          raise OpenAM::Auth::Error.new('verify token request results invalid')
        else
          if res.contentType =~ /\Atext\/plain/
            if /true\Z/.match(res.body)
              return true
            end
          end
        end

        return false
      end

      # method: login_url
      #
      def login_url(goto=nil)
        build_api(
          @config.login_uri,
          realm: @config.realm,
          goto: goto
        )
      end

      # method: logout_url
      #
      def logout_url(goto=nil)
        build_api(
          @config.logout_uri,
          realm: @config.realm,
          goto: goto
        )
      end

      private

      def get_cookie_name
        res = OpenAM::Auth::HTTP.get(build_api(@config.cookie_api))

        if res.body.nil? || res.contentType.nil?
          raise OpenAM::Auth::Error.new('returned cookie name is invalid')
        else
          if res.contentType =~ /\Atext\/plain/
            if res.body =~ /\Astring\=.*\Z/
              res.body.gsub(/\Astring\=/, "")
            else
              @config.cookie_name
            end
          else
            @config.cookie_name
          end
        end
      end
      
      def build_api(uri=nil,*opts)
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
      
      class JsonResult
      
        def initialize(json=nil)
          @json_data = {}
          
          if json.nil?
            raise OpenAM::Auth::Error.new('JSON data is invalid')
          else
            JSON.parse(json).each do |i|
              key = i.shift
              value = i.shift
              @json_data[key.to_sym] = value
            end
          end
        end
        
        def [](key)
          @json_data[key.to_sym]
        end
        
        def udefine(key,*opts)
          if !key.nil?
            key = key.to_s
            @json_data[key.to_sym]
          end
        end
        alias method_missing udefine
        
      end

    end
  end
end
