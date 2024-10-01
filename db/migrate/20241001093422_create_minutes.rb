class CreateMinutes < ActiveRecord::Migration[7.2]
  def change
    create_table :minutes do |t|
      t.string :release_branch
      t.string :release_note
      t.text :other
      t.date :meeting_date
      t.date :next_meeting_date
      t.datetime :notified_at
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
