require_relative '_lib'

describe SimpleRestClient::ParamsArray do

  describe '.new' do
    it 'accepts various types of containers' do
      as_array = [[:foo, 123], [:foo, 456], [:bar, 789], [:empty, nil]]
      [
        [[:foo, 123], [:foo, 456], [:bar, 789], [:empty, nil]],
        [{foo: 123}, {foo: 456}, {bar: 789}, {empty: nil}],
        [{foo: 123}, {foo: 456}, {bar: 789}, {empty: nil}],
        [{foo: 123}, [:foo, 456], {bar: 789}, {empty: nil}],
        [{foo: 123}, [:foo, 456], {bar: 789}, [:empty]],
      ].each do |input|
        expect(SimpleRestClient::ParamsArray.new(input).to_a).to eq as_array
      end

      expect(SimpleRestClient::ParamsArray.new([]).to_a).to eq []
      expect(SimpleRestClient::ParamsArray.new([]).empty?).to eq true
    end

    it 'rejects various invalid input' do
      expect {
        SimpleRestClient::ParamsArray.new([[]])
      }.to raise_error(IndexError)

      expect {
        SimpleRestClient::ParamsArray.new([[1,2,3]])
      }.to raise_error(ArgumentError)

      expect {
        SimpleRestClient::ParamsArray.new([1,2,3])
      }.to raise_error(NoMethodError)
    end
  end
end
