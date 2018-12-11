class CreateSources < ActiveRecord::Migration[5.2]
  def change
    create_table :sources do |t|
      t.string :channel, null: false
      t.string :address, null: false

      t.timestamps
    end
    add_index :sources, [:channel, :address], unique: true
  end
end
