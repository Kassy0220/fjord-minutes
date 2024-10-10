class AddCourseRefToMembers < ActiveRecord::Migration[7.2]
  def change
    add_reference :members, :course, null: false, foreign_key: true
  end
end
