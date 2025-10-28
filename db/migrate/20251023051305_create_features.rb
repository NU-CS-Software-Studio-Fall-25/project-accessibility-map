class CreateFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :features, id: :uuid do |t|
      t.text :feature

      t.timestamps
    end
  end
end
