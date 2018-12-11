class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.string :uuid
      t.string :title
      t.string :location
      t.text :message
      t.datetime :publish_at
      t.datetime :effective_at
      t.datetime :expires_at

      t.timestamps
    end
    add_index :alerts, :uuid, unique: true
  end
end
