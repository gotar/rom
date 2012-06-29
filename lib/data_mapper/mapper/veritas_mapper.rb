module DataMapper
  class Mapper

    # VeritasMapper
    #
    # @api public
    class VeritasMapper < Mapper
      TAUTOLOGY = Veritas::Function::Proposition::Tautology.instance

      # @api public
      def self.find(conditions = {})
        restriction = relation.restrict do |r|
          conditions.inject(TAUTOLOGY) do |predicate, (attribute, value)|
            field = attributes[attribute].field
            predicate.and(r.send(field).eq(value))
          end
        end

        new(restriction)
      end

      # @api public
      def self.one(conditions = {})
        results = find(conditions).to_a

        if results.size == 1
          results.first
        else
          # TODO: add custom error class
          raise "#{self}.one returned more than one result"
        end
      end

      def self.relation
        @relation ||= DataMapper[model].relation
      end

      # @api public
      def self.base_relation
        @base_relation ||= Veritas::Relation::Base.new(
          relation_name, attributes.header)
      end

      # @api private
      attr_reader :relation

      # Initialize a veritas mapper instance
      #
      # @param [Veritas::Relation]
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation)
        @relation      = relation
        @attributes    = self.class.attributes
        @relationships = self.class.relationships
        @model         = self.class.model
      end

      # @api public
      def each
        return to_enum unless block_given?
        @relation.each { |tuple| yield load(tuple) }
        self
      end

      # @api public
      def include(name)
        self.class.new(@relationships[name].join(@relation))
      end

      # @api public
      def restrict(&block)
        self.class.new(@relation.restrict(&block))
      end

      # @api public
      def sort_by(&block)
        self.class.new(@relation.sort_by(&block))
      end

      # @api private
      def load(tuple)
        @model.new(
          @attributes.load(tuple).merge(@relationships.load(tuple)))
      end

      # @api public
      def dump(object)
        @attributes.each_with_object({}) do |attribute, attributes|
          attributes[attribute.field] = object.send(attribute.name)
        end
      end

    end # class VeritasMapper
  end # class Mapper
end # module DataMapper
