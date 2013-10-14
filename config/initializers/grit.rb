require "grit"

Grit.logger = Rails.logger

class Grit::Ref
  def ==(other)
    name == other.name && commit == other.commit
  end
end

class Grit::Repo
  def update_head(target_head)
    if heads.include?(target_head)
      File.open(File.join(self.path, "HEAD"), 'w') do |f|
        f.puts "ref: refs/heads/#{target_head.name}"
      end
      @__head = nil
      return true
    end
    false
  end
end

class Grit::Commit
  include Comparable

  def <=>(other)
    sha <=> other.sha
  end

  def merge?
    parents.length > 1
  end
end

class Grit::Blob
  def binary?
    data[0..1024].include?("\000")
  rescue Grit::Git::GitTimeout
    # assuming binary for large blobs might be a tad too clever...
    return true
  end
end

module Grit
  class Diff
    include ForceUTF8

    def diff
      if @diff.nil?
        @diff = ""
      else
        lines = @diff.lines.to_a
        path = force_utf8(lines.shift(2).join)
        body = force_utf8(lines.join)
        @diff = path + body
      end
    end
  end
end
