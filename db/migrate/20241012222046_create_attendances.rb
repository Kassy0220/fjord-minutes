class CreateAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :attendances do |t|
      t.integer :status, null: false
      t.integer :time
      t.string :absence_reason
      t.string :progress_report
      t.references :minute, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
