# frozen_string_literal: true

class AttendanceForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :status, :string
  attribute :absence_reason, :string
  attribute :progress_report, :string

  validates :status, presence: { message: "#{AttendanceForm.human_attribute_name('status')}を選択してください" }
  validates :absence_reason, presence: true, if: -> { status == 'absent' }
  validates :progress_report, presence: true, if: -> { status == 'absent' }

  attr_accessor :attendance

  def initialize(model: nil, minute: nil, member: nil, **attrs)
    attrs.symbolize_keys!
    if model
      @attendance = model
      @minute = @attendance.minute || minute
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
      { url: Rails.application.routes.url_helpers.minute_attendances_path(@minute), method: :post }
    end
  end

  private

  def transfer_attributes_from_model
    return {} if attendance.present.nil? # model: Attendance.new が渡された場合は空のハッシュを返しておく

    if attendance.present?
      { status: attendance.session }
    else
      { status: 'absent', absence_reason: attendance.absence_reason, progress_report: attendance.progress_report }
    end
  end

  def transfer_attributes_to_model
    attendance.minute = @minute
    attendance.member = @member

    if status == 'absent'
      attendance.present = false
      attendance.session = nil
      attendance.absence_reason = absence_reason
      attendance.progress_report = progress_report
    else
      attendance.present = true
      attendance.session = status
      attendance.absence_reason = nil
      attendance.progress_report = nil
    end
  end
end
