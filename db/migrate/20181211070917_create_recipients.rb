class CreateRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :recipients do |t|
      t.string :channel, null: false
      t.string :address, null: false

      t.timestamps
    end
    add_index :recipients, [:channel, :address], unique: true
  end
end
