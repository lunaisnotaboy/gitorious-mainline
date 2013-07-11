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
require "gitorious/app"

class WebHooksController < ApplicationController
  renders_in_site_specific_context
  layout "ui3/layouts/application"
  before_filter :login_required

  rescue_from Gitorious::Authorization::UnauthorizedError do |err|
    flash[:error] = I18n.t("repositories_controller.adminship_error")
    repo = err.subject
    redirect_to(project_repository_path(repo.project, repo))
  end

  def index
    render(:index, :locals => {
        :repository => RepositoryPresenter.new(repository),
        :hooks => repository.web_hooks,
        :hook => WebHook.new(:repository => repository)
      })
  end

  def create
    uc = CreateWebHook.new(Gitorious::App, repository, current_user)
    outcome = uc.execute(:url => params[:web_hook][:url])
    pre_condition_failed(outcome)

    outcome.failure do |validation|
      render(:create, :locals => {
          :repository => RepositoryPresenter.new(repository),
          :hook => validation
        })
    end

    outcome.success { |hook| redirect_to(:action => :index) }
  end

  def destroy
    hook = repository.web_hooks.find(params[:id])
    hook.destroy
    redirect_to(project_repository_web_hooks_path(repository.project, repository))
  end

  private
  def repository
    return @repository if @repository
    project = authorize_access_to(Project.find_by_slug!(params[:project_id]))
    @repository = authorize_access_to(project.repositories.find_by_name!(params[:repository_id]))

    unless Gitorious::App.admin?(current_user, @repository)
      raise Gitorious::Authorization::UnauthorizedError.new("Repository admin required", @repository)
    end

    @repository
  end
end
