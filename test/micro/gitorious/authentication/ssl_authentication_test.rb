# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "fast_test_helper"
require "authentication_test_helper"
require "gitorious/authentication/credentials"
require "gitorious/authentication/ssl_authentication"

class Gitorious::Authentication::SSLAuthenticationTest < MiniTest::Shoulda
  include Gitorious::SSLTestHelper

  context "Authentication" do
    setup do
      @ssl = Gitorious::Authentication::SSLAuthentication.new({})
    end

    should "return the actual user" do
      moe = User.new
      User.stubs(:find_by_login).with("moe").returns(moe)
      assert_equal(moe, @ssl.authenticate(valid_client_credentials("moe", "moe@example.com")))
    end
  end
end
