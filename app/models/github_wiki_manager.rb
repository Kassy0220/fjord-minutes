# frozen_string_literal: true

class GithubWikiManager
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze

  def self.export_minute(minute)
    new(minute.course).commit_and_push(minute)
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

  def commit_and_push(minute)
    @git.pull
    set_github_account
    commit_minute_markdown(minute)

    create_credential_file
    @git.push('origin', 'master') # GitHub Wiki のデフォルトブランチはmaster
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

  def create_credential_file
    credential_file_path = Rails.root.join('.netrc')
    return if File.exist?(credential_file_path)

    content = <<~CREDENTIAL
      machine github.com
      login #{ENV.fetch('GITHUB_USER_NAME', nil)}
      password #{ENV.fetch('GITHUB_ACCESS_TOKEN', nil)}
    CREDENTIAL

    File.open(credential_file_path, 'w+') do |file|
      file.puts content
    end
    File.chmod(0o400, credential_file_path)
  end

  def rails_course?
    @course.name == 'Railsエンジニアコース'
  end
end
