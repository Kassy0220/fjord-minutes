class RenameTimeColumnToAttendances < ActiveRecord::Migration[7.2]
  def change
    rename_column :attendances, :time, :session
  end
end
