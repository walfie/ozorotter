require 'ozorotter/dal/google_images'

RSpec.describe Ozorotter::Dal::GoogleImages do
  GoogleImages = Ozorotter::Dal::GoogleImages

  describe '#adjust_terms' do
    subject(:google) { GoogleImages.new }

    it 'excludes sensitive search terms' do
      adjusted = google.adjust_terms('whatever')

      terms = %w(-disaster -earthquake -tsunami -hurricane)
      terms.each { |term| expect(adjusted).to include(term) }
    end

    context "when term doesn't exist in the mappings" do
      it 'includes the original term' do
        adjusted = google.adjust_terms('whatever')
        expect(adjusted).to include('whatever')
      end
    end

    context "when term does not contain 'snow'" do
      it "adds '-snow'" do
        adjusted = google.adjust_terms('rain')
        expect(adjusted).to include('-snow')
      end
    end

    context "when term contains 'snow" do
      it "doesn't add '-snow'" do
        adjusted = google.adjust_terms('snowy')
        expect(adjusted).not_to include('-snow')
      end
    end
  end

  #TODO: Include more specs maybe
end

