require "spec_helper"

describe "WordDiff::Document" do

  before do
    @document = WordDiff::Document.new(
      :repo    => "benbalter/test-repo-ignore-me",
      :path    => "/file.docx",
      :ref     => "aae67a7e9c7097c1af8c7fcbf56c2a736f9e69ff",
      :tmpdir  => Dir.mktmpdir,
      :branch  => "master",
      :author  => { :email => "ben@example.com", :name => "Ben Balter" },
      :message => "[Word Diff] Convert /file.docx"
    )

    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.docx?ref=master").
       to_return(:status => 200, :body => File.open(fixture("contents.json")).read, :headers => {'Content-Type'=>'application/json'})
  end

  it "should know the markdown path" do
    expect(@document.md_path).to eql("/file.md")
  end

  it "knows the filename" do
    expect(@document.filename).to eql("file.docx")
  end

  it "knows the directory" do
    expect(@document.directory).to eql("/")
  end

  it "downloads the file" do
    @document.download
    expect(File.exists?(@document.local_path)).to eql(true)
    @document.cleanup
  end

  it "knows the local path" do
    expect(@document.local_path).to match(/\/file\.docx$/)
  end

  it "cleans up the temp file" do
    @document.download
    expect(File.exists?(@document.local_path)).to eql(true)
    @document.cleanup
    expect(File.exists?(@document.local_path)).to eql(false)
  end

  it "converts the document" do
    expect(@document.to_md).to match(/TEST TEST TEST/)
  end

  it "knows if the markdown file exists" do
    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})
    expect(@document.md_exists?).to eql(true)
  end

  it "knows when the markdown file doesn't exist" do
    fixture = File.open(fixture("md-doesnt-exist.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})
    expect(@document.md_exists?).to eql(false)
  end

  it "returns the md sha" do
    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})
    expect(@document.md_sha).to eql("fff6fe3a23bf1c8ea0692b4a883af99bee26fd3b")
  end

  it "creates the md file" do
    @document.instance_variable_set("@md", "")
    stub = stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         with(:body => "{\"branch\":\"master\",\"author\":{\"email\":\"ben@example.com\",\"name\":\"Ben Balter\"},\"content\":\"\",\"message\":\"[Word Diff] Convert /file.docx\"}").
         to_return(:status => 200)

    @document.create
    expect(stub).to have_been_requested
  end

  it "updates the md file" do
    @document.instance_variable_set("@md", "")
    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})

    stub = stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         with(:body => "{\"branch\":\"master\",\"author\":{\"email\":\"ben@example.com\",\"name\":\"Ben Balter\"},\"sha\":\"fff6fe3a23bf1c8ea0692b4a883af99bee26fd3b\",\"content\":\"\",\"message\":\"[Word Diff] Convert /file.docx\"}").
         to_return(:status => 200)

    @document.update
    expect(stub).to have_been_requested
  end

  it "converts the file when it exists" do
    @document.instance_variable_set("@md", "")
    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})

    stub = stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         with(:body => "{\"branch\":\"master\",\"author\":{\"email\":\"ben@example.com\",\"name\":\"Ben Balter\"},\"sha\":\"fff6fe3a23bf1c8ea0692b4a883af99bee26fd3b\",\"content\":\"\",\"message\":\"[Word Diff] Convert /file.docx\"}").
         to_return(:status => 200)

    @document.update
    expect(stub).to have_been_requested
  end

  it "converts the file when it doesn't exist" do
    @document.instance_variable_set("@md", "")
    stub = stub_request(:put, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         with(:body => "{\"branch\":\"master\",\"author\":{\"email\":\"ben@example.com\",\"name\":\"Ben Balter\"},\"content\":\"\",\"message\":\"[Word Diff] Convert /file.docx\"}").
         to_return(:status => 200)

    @document.create
    expect(stub).to have_been_requested
  end

  it "deletes the file" do
    fixture = File.open(fixture("md-exists.json")).read
    stub_request(:get, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/?ref=master").
        to_return(:status => 200, :body => fixture, :headers => {'Content-Type'=>'application/json'})

    stub = stub_request(:delete, "https://api.github.com/repos/benbalter/test-repo-ignore-me/contents/file.md").
         with(:body => "{\"branch\":\"master\",\"author\":{\"email\":\"ben@example.com\",\"name\":\"Ben Balter\"},\"message\":\"[Word Diff] Convert /file.docx\",\"sha\":\"fff6fe3a23bf1c8ea0692b4a883af99bee26fd3b\"}").
         to_return(:status => 200, :body => "", :headers => {})

    @document.delete
    expect(stub).to have_been_requested
  end
end
