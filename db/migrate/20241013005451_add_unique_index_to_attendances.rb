class AddUniqueIndexToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_index(:attendances, [ :minute_id, :member_id ], unique: true)
  end
end
