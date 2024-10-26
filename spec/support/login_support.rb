module LoginSupport
  def login_as(member)
    OmniAuth.config.add_mock(:github, { uid: member.uid,
                                        info: { nickname: member.name,
                                                email: member.email,
                                                image: member.avatar_url } })
    visit root_path
    click_button "#{member.course.name}でログイン"
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
