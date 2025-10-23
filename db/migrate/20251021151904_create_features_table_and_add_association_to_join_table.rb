class CreateFeaturesTableAndAddAssociationToJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table(:features) do |t|
      t.text(:feature)
    end 
  end
end
