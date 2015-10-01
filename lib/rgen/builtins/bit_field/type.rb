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
      end

      field :type
      field :readable?  , forward_to_helper:true
      field :writable?  , forward_to_helper:true
      field :read_only? , forward_to_helper:true
      field :write_only?, forward_to_helper:true
      field :reserved?  , forward_to_helper:true

      class_delegator :required_width

      build do |cell|
        @type       = cell.to_sym.downcase
      end

      validate do
        case
        when mismatch_width?
          error "#{required_width} bit(s) width required:" \
                " #{bit_field.width} bit(s)"
        end
      end

      def mismatch_width?
        return false if required_width.nil?
        return false if bit_field.width == required_width
        true
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