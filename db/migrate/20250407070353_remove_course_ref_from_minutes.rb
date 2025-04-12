class RemoveCourseRefFromMinutes < ActiveRecord::Migration[7.2]
  def change
    remove_reference :minutes, :course, foreign_key: true
  end
end
