# == Schema Information
#
# Table name: anime
#
#  id                        :integer          not null, primary key
#  slug                      :string(255)
#  age_rating                :integer
#  episode_count             :integer
#  episode_length            :integer
#  synopsis                  :text             default(""), not null
#  youtube_video_id          :string(255)
#  mal_id                    :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cover_image_file_name     :string(255)
#  cover_image_content_type  :string(255)
#  cover_image_file_size     :integer
#  cover_image_updated_at    :datetime
#  average_rating            :float
#  user_count                :integer          default(0), not null
#  thetvdb_series_id         :integer
#  thetvdb_season_id         :integer
#  age_rating_guide          :string(255)
#  show_type                 :integer
#  start_date                :date
#  end_date                  :date
#  rating_frequencies        :hstore           default({}), not null
#  poster_image_file_name    :string(255)
#  poster_image_content_type :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  cover_image_top_offset    :integer          default(0), not null
#  ann_id                    :integer
#  started_airing_date_known :boolean          default(TRUE), not null
#  titles                    :hstore           default({}), not null
#  canonical_title           :string           default("ja_en"), not null
#  abbreviated_titles        :string           is an Array
#

require 'rails_helper'

RSpec.describe Anime, type: :model do
  include_examples 'media'

  describe '#recalculate_episode_length!' do
    it 'should set episode_length to the mode when it is more than 50%' do
      anime = create(:anime, episode_count: 10)
      expect(Episode).to receive(:length_mode) { {mode: 5, count: 8} }
      expect(anime).to receive(:update).with(episode_length: 5)
      anime.recalculate_episode_length!
    end
    it 'should set episode_length to the mean when mode is less than 50%' do
      anime = create(:anime, episode_count: 10)
      allow(Episode).to receive(:length_mode) { {mode: 5, count: 2} }
      expect(Episode).to receive(:length_average) { 10 }
      expect(anime).to receive(:update).with(episode_length: 10)
      anime.recalculate_episode_length!
    end
  end

  describe '#sfw?' do
    it 'should be true for a G-rated show' do
      anime = build(:anime, age_rating: 'G')
      expect(anime).to be_sfw
      expect(anime).not_to be_nsfw
    end
    it 'should be false for an R18-rated show' do
      anime = build(:anime, :nsfw)
      expect(anime).not_to be_sfw
      expect(anime).to be_nsfw
    end
  end

  describe 'sfw scope' do
    it 'should not include any nsfw series' do
      5.times do
        create(:anime, :nsfw)
        create(:anime, age_rating: 'G')
      end
      expect(Anime.sfw.count).to eq(5)
    end
  end
end
