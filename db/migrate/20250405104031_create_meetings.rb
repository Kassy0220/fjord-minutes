class CreateMeetings < ActiveRecord::Migration[7.2]
  def change
    create_table :meetings do |t|
      t.date :date
      t.date :next_date
      t.datetime :notified_at
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
