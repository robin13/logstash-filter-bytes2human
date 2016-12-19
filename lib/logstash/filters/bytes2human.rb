require "logstash/filters/base"
require "logstash/filters/bytes2human/filesize"
require "logstash/namespace"

# The bytes2human filter allows conversion from text (e.g. 2.5 GB) to integer bytes
# or from integer bytes to human readable form
# It understands MB, MiB etc.

class LogStash::Filters::Bytes2Human < LogStash::Filters::Base
  config_name "bytes2human"

  # The fields which should be converted, and the direction to convert (human, bytes)
  # Example:
  #
  #     filter {
  #       bytes2human {
  #         # Converts 'data_size' field from 2.4 KB to 2400
  #         convert => { "data_size" => "bytes" }
  #       }
  #     }
  #     
  # or
  #
  #     filter {
  #       bytes2human {
  #         # Converts 'data_size' field from 123456 to "123.456 MB"
  #         convert => { "data_size" => "human" }
  #       }
  #     }
  config :convert, :validate => :hash

  public
  def register
    valid_directions = %w(human bytes)
    @convert.nil? or @convert.each do |field, direction|
      if !valid_directions.include?(direction)
        @logger.error("Invalid conversion direction", "direction" => direction, "expected one of" => valid_directions )
        # TODO: RCL 2014-03-19 propper 'configuration broken' exception
        raise "Bad configuration, aborting."
      end
    end # @convert.each
  end # def register

  public
  def filter(event)
    return unless filter?(event)
    convert(event) if @convert
    filter_matched(event)
  end # def filter

  def convert(event)
    @convert.each do |field, direction|
      next unless event.include?(field)
      original = event.get(field)
      
      if original.nil?
        next
      elsif original.is_a?(Hash)
        @logger.debug("I don't know how to type convert a hash, skipping",
                      :field => field, :value => original)
        next
      elsif original.is_a?(Array)
        if direction == "human"
          value = original.map { |v| Filesize.from(v.to_s + " B").pretty.force_encoding("UTF-8") }
        else
          value = original.map { |v| Filesize.from(v).to_i }
        end
      else
        if direction == "human"
          value = Filesize.from(original.to_s + " B").pretty.force_encoding("UTF-8")
        else
          value = Filesize.from(original).to_i;
        end
      end
      event.set(field, value)
    end
  end # def convert

end # class LogStash::Filters::Bytes2Human

