class ChangeDataTypeProgressReportOfAttendances < ActiveRecord::Migration[7.2]
  def change
    change_column :attendances, :progress_report, :text
  end
end
