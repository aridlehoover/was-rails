class CreateRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :recipients do |t|
      t.string :channel
      t.string :address

      t.timestamps
    end
  end
end
