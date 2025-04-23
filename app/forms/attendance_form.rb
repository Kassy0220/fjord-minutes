# frozen_string_literal: true

class AttendanceForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :status, :string
  attribute :absence_reason, :string
  attribute :progress_report, :string

  validates :status, presence: true
  validates :absence_reason, presence: true, if: -> { status == 'absent' }
  validates :progress_report, presence: true, if: -> { status == 'absent' }

  attr_accessor :attendance

  def initialize(model: nil, meeting: nil, member: nil, **attrs)
    attrs.symbolize_keys!
    if model
      @attendance = model
      @meeting = @attendance.meeting || meeting
      @member = @attendance.member || member
      attrs = transfer_attributes_from_model.merge(attrs)
    end
    super(**attrs)
  end

  def save(...)
    return false unless valid?

    transfer_attributes_to_model
    attendance.save(...)
  end

  def form_with_options
    if attendance.persisted?
      { url: Rails.application.routes.url_helpers.attendance_path(attendance), method: :patch }
    else
      { url: Rails.application.routes.url_helpers.meeting_attendances_path(@meeting), method: :post }
    end
  end

  private

  def transfer_attributes_from_model
    return {} if attendance.attended.nil? # model: Attendance.new が渡された場合は空のハッシュを返しておく

    if attendance.attended?
      { status: attendance.session }
    else
      { status: 'absent', absence_reason: attendance.absence_reason, progress_report: attendance.progress_report }
    end
  end

  def transfer_attributes_to_model
    attendance.meeting = @meeting
    attendance.member = @member

    if status == 'absent'
      attendance.attended = false
      attendance.session = nil
      attendance.absence_reason = absence_reason
      attendance.progress_report = progress_report
    else
      attendance.attended = true
      attendance.session = status
      attendance.absence_reason = nil
      attendance.progress_report = nil
    end
  end
end
