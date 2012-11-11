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
require "minitest/autorun"
require "gitorious/configurable"

class ConfigurationTest < MiniTest::Spec
  before do
    @config = Gitorious::Configurable.new("MYLIB")
  end

  after do
    ENV.delete("MYLIB_THINGIE")
  end

  describe "append" do
    it "gets key from only settings set" do
      @config.append("prop" => 42)

      assert_equal 42, @config.get("prop")
    end

    it "gets key from first matching set" do
      @config.append("prop" => 42)
      @config.append("prop" => 12)

      assert_equal 42, @config.get("prop")
    end

    it "gets key from any matching set" do
      @config.append("something" => 42)
      @config.append("prop" => 12)

      assert_equal 12, @config.get("prop")
    end

    it "removes settings set" do
      settings = @config.append("prop" => 42)
      @config.append("prop" => 12)
      @config.prune(settings)

      assert_equal 12, @config.get("prop")
    end
  end

  describe "prepend" do
    it "gets key from only settings set" do
      @config.prepend("prop" => 42)

      assert_equal 42, @config.get("prop")
    end

    it "gets key from first matching set" do
      @config.prepend("prop" => 42)
      @config.prepend("prop" => 12)

      assert_equal 12, @config.get("prop")
    end

    it "gets key from any matching set" do
      @config.prepend("something" => 42)
      @config.prepend("prop" => 12)

      assert_equal 12, @config.get("prop")
    end

    it "removes settings set" do
      @config.prepend("prop" => 42)
      settings = @config.prepend("prop" => 12)
      @config.prune(settings)

      assert_equal 42, @config.get("prop")
    end
  end

  describe "environment variables" do
    it "prefers environment variable" do
      ENV["MYLIB_THINGIE"] = "use it!"
      @config.append("thingie" => 12)

      assert_equal "use it!", @config.get("thingie")
    end
  end

  describe "default values" do
    it "does not call default block if not needed" do
      @config.append("thingie" => 12)
      called = false
      value = @config.get("thingie") { called = true; 42 }

      assert_equal 12, value
      refute called
    end

    it "calls default block when no value available" do
      assert_equal 42, @config.get("blocked") { 42 }
    end

    it "does not use default callback when value is false" do
      @config.append("use_something" => false)
      assert_equal false, @config.get("use_something", true)
    end
  end
end
