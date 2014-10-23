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

      def logout(token=nil)
        if token.nil?
          raise OpenAM::Auth::Error.new('token value is invalid')
        else
          if verify_token token
            OpenAM::Auth::HTTP.post(
              @config.logout_api,
              :headers => {
                OpenAM::Auth.cookie_name => token,
                'Content-Type' => 'application/json'
              }
            )
          end
        end
      end

      def verify_token(token=nil)
        if token.nil?
          raise OpenAM::Auth::Error.new('token value is invalid')
        else
          results = OpenAM::Auth::HTTP.post(
            @config.token_api,
            :body => {
              'tokenid' => token
            }
          )

          if !results.nil?
            if /true\z/.match(results)
              return true
            end
          end
        end

        return false
      end

      def login_url(goto=nil)
        OpenAM::Auth::HTTP.build(
          @config.login_uri,
          realm: @config.realm,
          goto: goto
        )
      end

      def logout_url(goto=nil)
        OpenAM::Auth::HTTP.build(
          @config.logout_uri,
          realm: @config.realm,
          goto: goto
        )
      end

      private

      def get_cookie_name
        name = OpenAM::Auth::HTTP.get(@config.cookie_api)
        if name.nil?
          raise OpenAM::Auth::Error.new('returned cookie name is invalid')
        else
          if name =~ /\Astring\=.*\Z/
            name.gsub(/\Astring\=/, "")
          else
            @config.cookie_name
          end
        end
      end

    end
  end
end
