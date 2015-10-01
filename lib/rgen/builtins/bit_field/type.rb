RGen.list_item(:bit_field, :type) do
  register_map do
    item_base do
      define_helpers do
        def read_write
          @readable = true
          @writable = true
        end

        def read_only
          @readable = true
          @writable = false
        end

        def write_only
          @readable = false
          @writable = true
        end

        def reserved
          @readable = false
          @writable = false
        end

        def readable?
          @readable.nil? || @readable
        end

        def writable?
          @writable.nil? || @writable
        end

        def read_only?
          readable? && !writable?
        end

        def write_only?
          writable? && !readable?
        end

        def reserved?
          !(readable? || writable?)
        end

        attr_setter :required_width

        def use_reference(options = {})
          @use_reference      = true
          @reference_options  = options
        end

        attr_reader :reference_options

        def use_reference?
          @use_reference || false
        end

        def same_width
          :same_width
        end
      end

      field :type
      field :readable?  , forward_to_helper:true
      field :writable?  , forward_to_helper:true
      field :read_only? , forward_to_helper:true
      field :write_only?, forward_to_helper:true
      field :reserved?  , forward_to_helper:true

      class_delegator :required_width
      class_delegator :use_reference?
      class_delegator :reference_options
      class_delegator :same_width

      build do |cell|
        @type = cell.to_sym.downcase
      end

      validate do
        case
        when mismatch_width?
          error "#{required_width} bit(s) width required:" \
                " #{bit_field.width} bit(s)"
        when required_refercne_not_exist?
          error "reference bit field required"
        when reference_width_mismatch?
          error "#{required_reference_width} bit(s) reference bit field" \
                " required: #{bit_field.reference.width}"
        end
      end

      def mismatch_width?
        return false if required_width.nil?
        return false if bit_field.width == required_width
        true
      end

      def required_refercne_not_exist?
        return false unless use_reference?
        return false unless reference_options[:required]
        return false if bit_field.has_reference?
        true
      end

      def reference_width_mismatch?
        return false unless use_reference?
        return false unless bit_field.has_reference?
        bit_field.reference.width != required_reference_width
      end

      def required_reference_width
        return 1 unless reference_options[:width]
        return bit_field.width if reference_options[:width] == same_width
        reference_options[:width]
      end
    end

    factory do
      def select_target_item(cell)
        type  = cell.value.to_sym.downcase
        @target_items.fetch(type) do
          error "unknown bit field type: #{type}", cell
        end
      end
    end
  end
end
