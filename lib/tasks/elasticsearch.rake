namespace :elasticsearch do
  desc "Create index if it doesn't exist"
  task create_index: :environment do
    Asset.reindex(import: false)
  end
end
