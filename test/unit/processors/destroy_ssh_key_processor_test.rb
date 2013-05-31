# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
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
require "ssh_key_test_helper"

class DestroySshKeyProcessorTest < ActiveSupport::TestCase
  include SshKeyTestHelper

  should "remove key from the authorized keys file" do
    ssh_key = new_key
    ssh_key.save!
    key = SshKeyFile.format(ssh_key)
    SshKeyFile.any_instance.expects(:delete_key).with(key)

    DestroySshKeyProcessor.new.on_message("id" => ssh_key.id)
  end
end