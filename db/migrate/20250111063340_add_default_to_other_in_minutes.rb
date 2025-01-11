class AddDefaultToOtherInMinutes < ActiveRecord::Migration[7.2]
  def change
    change_column_default(:minutes, :other, '')
  end
end
