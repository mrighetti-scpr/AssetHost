# require 'spec_helper'

# describe Asset do
#   it "truncates fields" do
#     too_big = 77777
#     asset = Asset.create title: "1" * too_big
#     expect(Asset::MAX_COL_LENGTH < too_big).to be true
#     expect(asset.title.length).to equal Asset::MAX_COL_LENGTH
#   end
# end
