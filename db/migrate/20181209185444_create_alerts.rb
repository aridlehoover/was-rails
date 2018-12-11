class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.string :uuid, null: false
      t.string :title, null: false
      t.string :location, null: false
      t.text :message
      t.datetime :publish_at, null: false
      t.datetime :effective_at
      t.datetime :expires_at

      t.timestamps
    end
    add_index :alerts, :uuid, unique: true
  end
end
