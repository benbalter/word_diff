require 'sinatra/base'
require 'json'
require 'pp'
require 'octokit'
require 'word-to-markdown'
require 'open3'
require 'tmpdir'
require 'dotenv'
require_relative "word_diff/document"

Dotenv.load

class WordDiff < Sinatra::Base

  attr_accessor :push

  def tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  def branch
    @branch ||= push["ref"].gsub(/^refs\/heads\//)
  end

  def self.client
    @client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
  end

  def push
    @push ||= JSON.parse(request.body.read)
  end

  post "/" do
    push["commits"].each do |commit|
      ["added", "removed", "modified"].each do |type|
        files = commit[type].select {|path| path =~ /\.docx?/i }
        files.each do |path|
          file = WordDiff::Document.new(
            :repo   => push["repository"]["full_name"],
            :path   => path,
            :ref    => commit["id"],
            :tmpdir => tmpdir,
            :branch => branch,
            :author => commit["author"]
          )
          if type == "removed"
            file.delete
          else
            file.convert
          end
        end
      end
    end
    halt 200
  end
end
