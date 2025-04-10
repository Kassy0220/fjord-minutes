class RemoveColumnsFromMinutes < ActiveRecord::Migration[7.2]
  def change
    remove_columns :minutes, :meeting_date, :next_meeting_date, :notified_at
  end
end
