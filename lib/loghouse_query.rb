require 'loghouse_query/parsers'
require 'loghouse_query/storable'
require 'loghouse_query/pagination'
require 'loghouse_query/clickhouse'
require 'loghouse_query/permissions'
require 'loghouse_query/csv'
require 'log_entry'

class LoghouseQuery
  include Parsers
  include Storable
  include Pagination
  include Clickhouse
  include Permissions
  include CSV

  DEFAULTS = {
    id:         nil,
    name:       nil,
    namespaces: [],
    query:      nil,
    time_from:  'now-15m',
    time_to:    'now',
    position:   nil
  }.freeze # Trick for all-attributes-hash in correct order in insert

  attr_accessor :attributes, :persisted

  def initialize(attrs = {})
    attrs.symbolize_keys!
    @attributes = DEFAULTS.dup
    @attributes.each do |k, v|
      @attributes[k] = attrs[k] if attrs[k].present?
    end
    @attributes[:id] ||= SecureRandom.uuid
  end

  def id
    attributes[:id]
  end

  def namespaces
    attributes[:namespaces]
  end

  def order_by
    [attributes[:order_by], "#{LogsTables::TIMESTAMP_ATTRIBUTE} DESC", "#{LogsTables::NSEC_ATTRIBUTE} DESC"].compact.join(', ')
  end

  def validate_query!
    parsed_query # sort of validation: will fail if query is not correct
  end

  def validate!
    super

    validate_query!
  end
end

require 'log_entry'
