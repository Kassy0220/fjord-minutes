class RenamePresentColumnToAttendances < ActiveRecord::Migration[7.2]
  def change
    rename_column :attendances, :present, :attended
  end
end
