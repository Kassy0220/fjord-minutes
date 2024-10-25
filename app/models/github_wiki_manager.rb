class GithubWikiManager
  BOOTCAMP_WIKI_WORKING_DIRECTORY = Rails.root.join("bootcamp_wiki_repository").freeze
  AGENT_WIKI_WORKING_DIRECTORY = Rails.root.join("agent_wiki_repository").freeze

  def self.export_minute(minute)
    new(minute).commit_and_push
  end

  def initialize(minute)
    @minute = minute
    @working_directory = rails_course? ? BOOTCAMP_WIKI_WORKING_DIRECTORY : AGENT_WIKI_WORKING_DIRECTORY
    wiki_url = rails_course? ? ENV["BOOTCAMP_WIKI_URL"] : ENV["AGENT_WIKI_URL"]
    @git = Dir.exist?(@working_directory) ? Git.open(@working_directory, log: Logger.new(STDOUT))
                                          : Git.clone(wiki_url, @working_directory)
  end

  def commit_and_push
    @git.pull
    set_github_account
    commit_minute_markdown

    create_credential_file
    @git.push("origin", "master") # GitHub Wiki のデフォルトブランチはmaster
  end

  private

  def set_github_account
    @git.config("user.name", ENV["GITHUB_USER_NAME"])
    @git.config("user.email", ENV["GITHUB_USER_EMAIL"])
  end

  def commit_minute_markdown
    filepath = "#{@working_directory}/#{@minute.title}.md"
    minute_markdown = MarkdownBuilder.build(@minute)

    File.open(filepath, "w+") do |file|
      file.write minute_markdown
    end

    @git.add("#{@minute.title}.md")
    @git.commit("#{@minute.title}.mdを作成")
  end

  def create_credential_file
    credential_file_path = Rails.root.join(".netrc")
    return if File.exist?(credential_file_path)

    content = <<~CREDENTIAL
      machine github.com
      login #{ENV["GITHUB_USER_NAME"]}
      password #{ENV["GITHUB_ACCESS_TOKEN"]}
    CREDENTIAL

    File.open(credential_file_path, "w+") do |file|
      file.puts content
    end
    File.chmod(0400, credential_file_path)
  end


  def rails_course?
    @minute.course.name == "Railsエンジニアコース"
  end
end
