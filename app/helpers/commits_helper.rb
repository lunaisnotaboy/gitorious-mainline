# encoding: utf-8
#--
#   Copyright (C) 2012-2014 Gitorious AS
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#   Copyright (C) 2008 Johan Sørensen <johan@johansorensen.com>
#   Copyright (C) 2008 Tor Arne Vestbø <tavestbo@trolltech.com>
#   Copyright (C) 2008 Tor Arne Vestbø <tor.arne.vestbo@trolltech.com>
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

module CommitsHelper
  include RepositoriesHelper
  include CommentsHelper
  include DiffHelper

  def format_commit_message(message)
    return nil if message.nil?
    message.force_utf8.gsub(/\b[a-z0-9]{40}\b/) do |match|
      link_to(match, project_repository_commit_path(@project, @repository, match), :class => "sha")
    end.html_safe
  end

  def parse_commit_message(message)
    lines = message.split("\n")
    summary = nil

    if !lines.empty? && lines.first.length <= 50
      summary = lines.shift
    end

    [summary, lines.join("\n").strip].map { |m| format_commit_message(m) }
  end
end
