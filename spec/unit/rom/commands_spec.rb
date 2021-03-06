require 'spec_helper'

describe 'Commands' do
  include_context 'users and tasks'

  let(:users) { rom.relations.users }

  before { setup.relation(:users) }

  describe '.build' do
    it 'returns create command when type is set to :create' do
      klass = Class.new(ROM::Commands::Create[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Create)
    end

    it 'returns update command when type is set to :update' do
      klass = Class.new(ROM::Commands::Update[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Update)
    end

    it 'returns delete command when type is set to :delete' do
      klass = Class.new(ROM::Commands::Delete[:memory]) do
        relation :users
      end

      command = klass.build(users)

      expect(command).to be_kind_of(ROM::Memory::Commands::Delete)
    end
  end

  describe '.registry' do
    it 'builds a hash with commands grouped by relations' do
      commands = {}

      [:Create, :Update, :Delete].each do |command_type|
        klass = Class.new(ROM::Commands.const_get(command_type)) do
          relation :users
        end
        klass.class_eval "def self.name; 'Test::#{command_type}'; end"
        commands[command_type] = klass
      end

      registry = ROM::Command.registry(rom.relations)

      expect(registry).to eql(
        users: {
          create: commands[:Create].build(users),
          update: commands[:Update].build(users),
          delete: commands[:Delete].build(users)
        }
      )
    end
  end
end
