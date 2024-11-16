class AddCompletedAtToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :completed_at, :date, default: nil
  end
end
