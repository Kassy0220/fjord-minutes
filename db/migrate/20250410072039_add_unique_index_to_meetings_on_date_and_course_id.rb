class AddUniqueIndexToMeetingsOnDateAndCourseId < ActiveRecord::Migration[7.2]
  def change
    add_index(:meetings, [ :date, :course_id ], unique: true)
  end
end
