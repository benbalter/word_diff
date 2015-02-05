class WordDiff < Sinatra::Base
  class Document

    HOST = "https://github.com"

    attr_accessor :repo, :ref, :path, :tmpdir, :branch

    def initialize(options)
      @repo   = options[:repo]
      @ref    = options[:ref]
      @path   = options[:path]
      @tmpdir = options[:tmpdir] || Dir.mktmpdir
      @branch = options[:branch]
      @author = options[:author]
    end

    def md_path
      @md_path ||= path.gsub(/\.docx?$/i, ".md")
    end

    def raw_path
      "#{HOST}/#{repo}/raw/#{ref}/#{path}"
    end

    def filename
      @filename ||= File.basename(path)
    end

    def directory
      @directory ||= File.dirname(path)
    end

    def download
      output, status = Open3.capture2e("wget", raw_path, "-O", local_path, "--quiet")
      local_path unless status != 0
    end

    def local_path
      @local_path ||= File.expand_path(filename, tmpdir)
    end

    def cleanup
      File.delete local_path
    end

    def to_md
      @md ||= begin
        download
        md = WordToMarkdown.new(local_path).to_s
        cleanup
        md
      end
    end

    def md_exists?
      !!(md_sha)
    end

    def md_sha
      @md_sha ||= begin
        file = WordDiff.client.contents(repo, :path => directory).find { |f| f[:path] == md_path }
        file[:sha] if file
      end
    end

    def convert
      md_exists? ? update : create
    end

    def create
      WordDiff.client.create_contents(
        repo,              # Repo
        md_path,           # Path
        "Convert #{path}", # Commit message
        to_md,             # Content
        {                  # Options
          :branch => branch,
          :author => author
        }
      )
    end

    def update
      WordDiff.client.update_contents(
        repo,              # Repo
        md_path,           # Path
        "Convert #{path}", # Commit message
        md_sha,            # Blob Sha
        to_md,             # Content
        {                  # Options
          :branch => branch,
          :author => author
        }
      )
    end

    def delete
      WordDiff.client.delete_conents(
        repo,                  # Repo
        md_path,               # Path
        "Deleting #{md_path}", # Commit message
        md_sha,                # Blob sha
        {                      # Options
          :branch => branch,
          :author => author
        }
      )
    end
  end
end
