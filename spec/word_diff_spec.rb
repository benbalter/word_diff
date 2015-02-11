require "spec_helper"

describe "WordDiff" do

  include Rack::Test::Methods

  def app
    WordDiff.new
  end

  it "inits the octokit client" do
    expect(WordDiff.client.class).to eql(Octokit::Client)
  end

  it "parses the push" do
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.docx?ref=master").
       to_return(:status => 200, :body => File.open(fixture("contents.json")).read, :headers => {'Content-Type'=>'application/json'})

    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})

    stub = stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         to_return(:status => 200)

    post "/", File.open(fixture("push.json")).read, "HTTP_X_HUB_SIGNATURE" => "sha1=c01c3556a785169da103e1d3599e40e412e4aa5b"

    expect(stub).to have_been_requested
  end

  it "verifies the signature" do
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.docx").
       to_return(:status => 200, :body => File.open(fixture("contents.json")).read, :headers => {'Content-Type'=>'application/json'})

    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})

    stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         to_return(:status => 200)

    post "/", File.open(fixture("push.json")).read

    expect(last_response.status).to eql(401)
  end

end
