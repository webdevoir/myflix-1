require 'spec_helper'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items for the authenticated user' do
      alice = Fabricate(:user)
      set_current_user(alice)
      queue_item_one = Fabricate(:queue_item, user: alice)
      queue_item_two = Fabricate(:queue_item, user: alice)

      get :index

      expect(assigns(:queue_items)).to match_array([queue_item_one, queue_item_two])
    end

    it_behaves_like 'requires sign in' do
      let(:action) { get :index }
    end
  end
  
  describe 'POST create' do
    context 'for authenticated users' do
      let(:alice) { Fabricate(:user) }
      before { set_current_user(alice) }

      it 'creates a queue item' do
        video = Fabricate(:video)

        post :create, video_id: video.id 
        
        expect(QueueItem.count).to eq(1)
      end

      it 'creates a queue item that is associated with the video' do
        video = Fabricate(:video)

        post :create, video_id: video.id 
        
        expect(QueueItem.first.video).to eq(video)
      end

      it 'creates a queue item that is associated with the user' do
        video = Fabricate(:video)

        post :create, video_id: video.id 
        
        expect(QueueItem.first.user).to eq(alice)
      end

      it 'puts the video as the last one in the queue' do
        video = Fabricate(:video)
        queue_item_one = Fabricate(:queue_item)

        post :create, video_id: video.id 
        
        expect(QueueItem.last.position).to eq(2)
      end

      it 'does not create add the video to the queue if it is already in the queue' do
        video = Fabricate(:video)
        Fabricate(:queue_item, video: video, user: alice)

        post :create, video_id: video.id 
        
        expect(QueueItem.count).to eq(1)
      end
      
      it 'redirects to the my queue page' do
        video = Fabricate(:video)

        post :create, video_id: video.id

        expect(response).to redirect_to my_queue_path
      end
    end

    it_behaves_like 'requires sign in' do
      let(:action) { post :create, video_id: 3 }
    end
  end

  describe 'DELETE destroy' do
    context 'for authenticated users' do
      let(:alice) { Fabricate(:user) }
      before { set_current_user(alice) }
      
      it 'removes the video from the queue' do
        queue_item = Fabricate(:queue_item, user: alice)
        
        delete :destroy, id: queue_item.id

        expect(QueueItem.count).to eq(0)
      end

      it 'normalizes the remaining queue items' do
        queue_item_one = Fabricate(:queue_item, user: alice, position: 1)
        queue_item_two = Fabricate(:queue_item, user: alice, position: 2)
        queue_item_three = Fabricate(:queue_item, user: alice, position: 3)

        delete :destroy, id: queue_item_two.id

        expect(alice.queue_items.map(&:position)).to eq([1, 2])
      end

      it 'does not remove the queue item if the current user does not own it' do
        queue_item = Fabricate(:queue_item, user: Fabricate(:user))
        
        delete :destroy, id: queue_item.id

        expect(QueueItem.count).to eq(1)
      end

      it 'redirects to the my queue page' do
        queue_item = Fabricate(:queue_item)
        
        delete :destroy, id: queue_item.id

        expect(response).to redirect_to my_queue_path
      end
    end
    
    it_behaves_like 'requires sign in' do
      let(:action) { delete :destroy, id: 1 }
    end
  end

  describe 'POST update_queue' do
    context 'with valid input' do
      let(:alice) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item_one) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
      let(:queue_item_two) { Fabricate(:queue_item, user: alice, position: 2, video: video) }
      before { set_current_user(alice) }
        
      it 'redirects to the my queue page' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 2}, { id: queue_item_two.id, position: 1}]

        expect(response).to redirect_to my_queue_path
      end

      it 'reorders the queue items' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 2 }, { id: queue_item_two.id, position: 1 }]

        expect(alice.queue_items).to eq([queue_item_two, queue_item_one])
      end

      it 'normalizes the position numbers' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 3 }, { id: queue_item_two.id, position: 2 }]

        expect(alice.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context 'with invalid input' do
      let(:alice) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item_one) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
      let(:queue_item_two) { Fabricate(:queue_item, user: alice, position: 2, video: video) }
      before { set_current_user(alice) }
    
      it 'redirects to my queue page' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 3 }, { id: queue_item_two.id, position: 2.35 }]

        expect(response).to redirect_to my_queue_path
      end

      it 'sets the flash danger message' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 3 }, { id: queue_item_two.id, position: 2.35 }]

        expect(flash[:danger]).to be_present
      end

      it 'does not reorder the queue items' do
        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 3 }, { id: queue_item_two.id, position: 2.35 }]

        expect(alice.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    it_behaves_like 'requires sign in' do
      let(:action) do
        post :update_queue, queue_items: [{ id: 1, position: 3 }, { id: 2, position: 2 }]
      end
    end

    context 'with queue items that do not belong to the current user' do
      it 'does not reorder queue items that do not belong to the current user' do
        alice = Fabricate(:user)
        set_current_user(alice)
        bob = Fabricate(:user)
        video = Fabricate(:video)
        queue_item_one = Fabricate(:queue_item, user: alice, position: 1, video: video)
        queue_item_two = Fabricate(:queue_item, user: bob, position: 2, video: video)

        post :update_queue, queue_items: [{ id: queue_item_one.id, position: 2 }, { id: queue_item_two.id, position: 1 }]

        expect(queue_item_two.reload.position).to eq(2)
      end
    end
  end
end
