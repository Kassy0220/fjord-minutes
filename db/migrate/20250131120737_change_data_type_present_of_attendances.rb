class ChangeDataTypePresentOfAttendances < ActiveRecord::Migration[7.2]
  def change
    change_column :attendances, :present, 'boolean USING CAST(present AS boolean)' , null: false
  end
end
