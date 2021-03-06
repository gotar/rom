require 'spec_helper'

describe ROM::Options do
  subject(:object) { klass.new(options) }

  let(:klass) do
    Class.new do
      include ROM::Options

      option :name, type: String, reader: true, allow: %w(foo bar)
      option :repo, reader: true
      option :other
    end
  end

  describe '.new' do
    it 'sets options hash' do
      object = klass.new(name: 'foo')
      expect(object.options).to eql(name: 'foo')
    end

    it 'allows any value when :allow is not specified' do
      repo = double('repo')
      object = klass.new(repo: repo)
      expect(object.options).to eql(repo: repo)
    end

    it 'sets readers for options when specified' do
      object = klass.new(name: 'bar', repo: 'default')
      expect(object.name).to eql('bar')
      expect(object.repo).to eql('default')
      expect(object).to_not respond_to(:other)
    end

    it 'checks option key' do
      expect { klass.new(unexpected: 'foo') }
        .to raise_error(ROM::InvalidOptionKeyError, /:unexpected/)
    end

    it 'checks option type' do
      expect { klass.new(name: :foo) }
        .to raise_error(ROM::InvalidOptionValueError, /:foo/)
    end

    it 'checks option value' do
      expect { klass.new(name: 'invalid') }
        .to raise_error(ROM::InvalidOptionValueError, /invalid/)
    end

    it 'copies klass options to descendant' do
      other = Class.new(klass)
      expect(other.option_definitions).to eql(klass.option_definitions)
    end
  end
end
