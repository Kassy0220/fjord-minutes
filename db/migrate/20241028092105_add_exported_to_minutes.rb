class AddExportedToMinutes < ActiveRecord::Migration[7.2]
  def change
    add_column :minutes, :exported, :boolean, default: false
  end
end
