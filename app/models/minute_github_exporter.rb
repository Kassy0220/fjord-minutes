# frozen_string_literal: true

class MinuteGithubExporter
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze

  def self.export_to_github_wiki(minute, github_account_name, access_token)
    new(minute.course).commit_and_push(minute, github_account_name, access_token)
  end

  attr_reader :working_directory

  def initialize(course)
    @course = course
    @working_directory = rails_course? ? CLONED_BOOTCAMP_WIKI_PATH : CLONED_AGENT_WIKI_PATH
    wiki_url = rails_course? ? ENV.fetch('BOOTCAMP_WIKI_URL', nil) : ENV.fetch('AGENT_WIKI_URL', nil)
    @git = if Dir.exist?(@working_directory)
             Git.open(@working_directory, log: Logger.new($stdout))
           else
             Git.clone(wiki_url, @working_directory)
           end
  end

  def commit_and_push(minute, github_account_name, access_token)
    @git.pull
    set_github_account
    commit_minute_markdown(minute)

    create_credential_file(github_account_name, access_token)
    begin
      @git.push('origin', 'master') # GitHub Wiki のデフォルトブランチはmaster
    ensure
      File.delete('.netrc')
    end
  end

  private

  def set_github_account
    @git.config('user.name', ENV.fetch('GITHUB_USER_NAME', nil))
    @git.config('user.email', ENV.fetch('GITHUB_USER_EMAIL', nil))
  end

  def commit_minute_markdown(minute)
    filename = "#{minute.title}.md"
    File.write(File.join(@working_directory, filename), MarkdownBuilder.build(minute))

    @git.add(filename)
    @git.commit("#{filename} committed")
  end

  def create_credential_file(github_account_name, access_token)
    credential_file_path = Rails.root.join('.netrc')

    content = <<~CREDENTIAL
      machine github.com
      login #{github_account_name}
      password #{access_token}
    CREDENTIAL

    File.open(credential_file_path, 'w+') do |file|
      file.puts content
    end
  end

  def rails_course?
    @course.name == 'Railsエンジニアコース'
  end
end
