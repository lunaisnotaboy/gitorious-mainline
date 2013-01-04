# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
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

require "test_helper"
require "test_cache_store"

class SiteControllerTest < ActionController::TestCase
  should_render_in_site_specific_context :except => [:about, :faq, :contact, :tos, :privacy_policy]
  should_render_in_global_context :only => [:about, :faq, :contact, :tos, :privacy_policy]

  def setup
    setup_ssl_from_config
  end

  context "#activity" do
    should "render the global activity timeline" do
      get :public_timeline
      assert_response :success
      assert_template "site/index"
    end
  end

  context "#index" do
    context "Logged in users" do
      setup {login_as users(:johan)}

      should "render the dashboard for logged in users" do
        login_as users(:johan)
        get :index
        assert_response :success
        assert_template "site/dashboard"
      end

      should "include the user's commit_repositories" do
        login_as users(:johan)
        get :index
        assert_not_nil assigns(:repositories)
      end

      should "render the dashboard breadcrumb" do
        login_as :johan
        get :index
        assert_instance_of Breadcrumb::Dashboard, assigns(:root)
      end
    end

    context "Anonymous users" do
      should "render the public timeline" do
        Gitorious::Configuration.override("is_gitorious_dot_org" => false) do
          get :index
          assert_response :success
          assert_template "site/index"
        end
      end

      should "not include any commit_repositories" do
        BlogFeed.any_instance.stubs(:fetch).returns([])
        get :index
        assert_nil assigns(:repositories)
      end
    end

    context "With private repositories" do
      setup do
        @project = Project.first
        enable_private_repositories
        @settings = Gitorious::Configuration.append("is_gitorious_dot_org" => false)
      end

      teardown do
        Gitorious::Configuration.prune(@settings)
      end

      should "not display unauthenticated projects" do
        login_as :mike
        get :index
        assert_response :success
        assert !assigns(:projects).index(@project)
      end

      should "not display unauthenticated repositories" do
        repositories(:johans).make_private
        users(:mike).commit_repositories << repositories(:johans)
        login_as :mike
        get :index
        assert_response :success
        assert_equal 0, assigns(:repositories).length
      end

      should "not display unauthenticated projects in public timeline" do
        logout
        projects = Project.all
        repos = Repository.all
        Project.stubs(:most_active_recently).returns(projects)
        Repository.stubs(:most_active_clones).returns(repos)

        get :index
        assert_response :success
        assert !assigns(:projects).index(@project)
        assert !assigns(:active_projects).index(@project)
        assert assigns(:top_repository_clones).none? { |r| r.project == @project }
        assert_not_equal assigns(:top_repository_clones).length, 0
      end

      should "not fragment cache the public timeline" do
        perform_caching = ActionController::Base.perform_caching
        old_cache_store = ActionController::Base.cache_store
        ActionController::Base.perform_caching = true
        cache_store = TestCacheStore.new
        ActionController::Base.cache_store = cache_store
        cache_store.expects(:write).never
        get :index
        assert_response :success
        ActionController::Base.perform_caching = perform_caching
        ActionController::Base.cache_store = old_cache_store
      end
    end
  end

  context "#index, with a non-default site" do
    setup do
      @controller.prepend_view_path(File.join(Rails.root, "test", "fixtures", "views"))
      @site = sites(:qt)
      @request.host = "#{@site.subdomain}.gitorious.test"
    end

    should "render the Site specific template" do
      get :index
      assert_response :success
      assert_template "#{@site.subdomain}/index"
    end

    should "scope the projects to the current site" do
      get :index
      assert_equal @site.projects, assigns(:projects)
    end

    context "With private repositories" do
      setup do
        @project = @site.projects.first
        enable_private_repositories
      end

      should "not display unauthenticated projects" do
        get :index
        assert_response :success
        assert !assigns(:projects).index(@project)
      end
    end
  end

  context "#dashboard" do
    setup do
      login_as :johan
    end

    should "requires login" do
      logout
      get :dashboard
      assert_redirected_to(new_sessions_path)
    end

    should "redirects to the user page" do
      get :dashboard
      assert_response :redirect
      assert_redirected_to user_path(users(:johan))
    end
  end

  context "in Private Mode" do
    setup do
      @settings = Gitorious::Configuration.append("is_gitorious_dot_org" => false)
    end

    teardown do
      Gitorious::Configuration.prune(@settings)
    end

    should "GET / should not show private content in the homepage" do
      Gitorious.stubs(:public?).returns(false)
      get :index

      assert_response 200
      assert_no_match(/Newest projects/, @response.body)
      assert_no_match(/action\=\"\/search"/, @response.body)
      assert_no_match(/Creating a user account/, @response.body)
      assert_no_match(/\/projects/, @response.body)
      assert_no_match(/\/search/, @response.body)
    end
  end
end
