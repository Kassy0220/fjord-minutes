# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesHelper, type: :helper do
  describe '#attendance_status' do
    it 'returns 昼 for afternoon session attendance' do
      expect(helper.attendance_status(true, 'afternoon')).to eq '昼'
    end

    it 'returns 夜 for night session attendance' do
      expect(helper.attendance_status(true, 'night')).to eq '夜'
    end

    it 'returns hyphen for unexcused absence' do
      expect(helper.attendance_status(nil, nil)).to eq '---'
    end
  end
end
