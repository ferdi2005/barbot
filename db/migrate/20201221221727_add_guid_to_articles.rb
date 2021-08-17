class AddGuidToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :guid, :string
  end
end
