class CreateHibernations < ActiveRecord::Migration[7.2]
  def change
    create_table :hibernations do |t|
      t.date :finished_at
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
