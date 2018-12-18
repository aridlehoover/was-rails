class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.string :import_type

      t.timestamps
    end
  end
end
