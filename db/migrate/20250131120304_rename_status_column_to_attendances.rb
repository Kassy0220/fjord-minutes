class RenameStatusColumnToAttendances < ActiveRecord::Migration[7.2]
  def change
    rename_column :attendances, :status, :present
  end
end
