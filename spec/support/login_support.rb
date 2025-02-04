# frozen_string_literal: true

module LoginSupport
  def login_as(member)
    OmniAuth.config.add_mock(:github, { uid: member.uid,
                                        info: { nickname: member.name,
                                                email: member.email,
                                                image: member.avatar_url } })
    visit root_path
    find('button', text: "#{member.course.name.delete_suffix('コース')}\nコースで登録").click
  end

  def login_as_admin(admin)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('KASSY_EMAIL', 'no_email').and_return(admin.email)
    OmniAuth.config.add_mock(:github, { uid: admin.uid,
                                        info: { nickname: admin.name,
                                                email: admin.email,
                                                image: admin.avatar_url } })
    visit root_path
    find('button', text: "Railsエンジニア\nコースで登録").click
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
