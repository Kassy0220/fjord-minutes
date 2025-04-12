class AddUniqueIndexToAttendancesOnMemberIdAndMeetingId < ActiveRecord::Migration[7.2]
  def change
    add_index(:attendances, [ :member_id, :meeting_id ], unique: true)
  end
end
