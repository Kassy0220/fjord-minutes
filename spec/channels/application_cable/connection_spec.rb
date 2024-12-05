# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:admin) { FactoryBot.create(:admin) }
  let(:member) { FactoryBot.create(:member) }

  it 'successfully connect when admin has valid remember cookie' do
    # ユーザーのログインを記憶する処理を簡易的に実行する
    # https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/controllers/rememberable.rb#L22
    admin.remember_me!
    cookies.signed[:remember_admin_token] = Admin.serialize_into_cookie(admin)

    connect
    expect(connection.current_development_member.id).to eq admin.id
  end

  it 'successfully connect when member has valid remember cookie' do
    member.remember_me!
    cookies.signed[:remember_member_token] = Member.serialize_into_cookie(member)

    connect
    expect(connection.current_development_member.id).to eq member.id
  end

  it 'does not connect without remember cookie' do
    member.remember_me!

    expect { connect }.to have_rejected_connection
  end

  it 'does not connect when resource is not found from cookie' do
    member.remember_me!
    cookies.signed[:remember_member_token] = Member.serialize_into_cookie(member)

    allow(Member).to receive(:serialize_from_cookie).and_return(nil)
    expect { connect }.to have_rejected_connection
  end
end
