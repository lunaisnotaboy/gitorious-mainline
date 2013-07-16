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
require "fast_test_helper"
require "commands/disable_standby_mode_command"

class DisableStandbyModeCommandTest < MiniTest::Shoulda
  def setup
    @base_path = File.join(Rails.root, 'tmp', 'standby-test')
    FileUtils.mkdir_p(@base_path)

    @authorized_keys_path = File.join(@base_path, 'authorized_keys')
    File.open(@authorized_keys_path, 'w') { |f| f.write('qux') }

    @public_path = File.join(@base_path, 'public')
    FileUtils.mkdir_p(File.join(@public_path, 'system'))
    FileUtils.touch(File.join(@public_path, 'system', 'standby.html'))

    @global_hooks_path = File.join(@base_path, 'hooks')
    old_hooks_path = File.join(@base_path, 'the-hooks')
    FileUtils.mkdir_p(old_hooks_path)
    FileUtils.ln_s(old_hooks_path, @global_hooks_path)

    @command = DisableStandbyModeCommand.new(@authorized_keys_path, @public_path,
                                            @global_hooks_path)
  end

  def teardown
    FileUtils.rm_rf(@base_path)
  end

  context "#execute" do
    should "disable the standby page" do
      @command.execute

      assert !File.exist?(File.join(@public_path, 'system', 'standby.html'))
    end

    should "enable all the git hooks" do
      @command.execute

      assert_equal File.expand_path('data/hooks'), File.readlink(@global_hooks_path)
    end

    should "re-generate authorized_keys file" do
      SshKeyFile.expects(:regenerate).with(@authorized_keys_path)
      @command.execute
    end
  end
end
