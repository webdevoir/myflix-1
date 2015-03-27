require 'spec_helper'

describe QueueItem do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:video) }
  
  describe '#video_title' do
    it 'returns the title of the associated video' do
      video = Fabricate(:video, title: 'Monk')
      queue_item = Fabricate(:queue_item, video: video)

      expect(queue_item.video_title).to eq('Monk')
    end
  end
  
  describe '#rating' do
    it 'returns an empty string when the user has not rated the associated videos' do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      queue_item = Fabricate(:queue_item, user: alice, video: video)

      expect(queue_item.rating).to eq('')
    end
    it 'returns the rating of the associated video' do
      alice = Fabricate(:user)
      video = Fabricate(:video)
      review = Fabricate(:review, video: video, author: alice, rating: 4)
      queue_item = Fabricate(:queue_item, user: alice, video: video)

      expect(queue_item.rating).to eq(4)
    end
  end

  describe '#category_name' do
    it 'returns the category name of the associated video' do
      category = Fabricate(:category, name: 'Comedies')
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)

      expect(queue_item.category_name).to eq(category.name)
    end
  end

  describe '#category' do
    it 'returns the category of the associated video' do
      category = Fabricate(:category)
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)

      expect(queue_item.category).to eq(category)
    end
  end
end