class AddUniqueIndexToMinutes < ActiveRecord::Migration[7.2]
  def change
    add_index(:minutes, [:meeting_date, :course_id], unique: true)
  end
end
