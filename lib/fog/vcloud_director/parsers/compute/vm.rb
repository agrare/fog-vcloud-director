require 'fog/vcloud_director/parsers/compute/vm_parser_helper'

module Fog
  module Parsers
    module Compute
      module VcloudDirector
        class Vm < VcloudDirectorParser
          include VmParserHelper

          def reset
            @in_operating_system = false
            @in_children = false
            @resource_type = nil
            @response = { :vm => initialize_vm }
            @links = []
          end

          def start_element(name, attributes)
            super
            if name == 'Vm'
              vm_attrs = extract_attributes(attributes)
              @response[:vm].merge!(vm_attrs.reject {|key,value| ![:href, :name, :status, :type, :deployed].include?(key)})
              @response[:vm][:id] = @response[:vm][:href].split('/').last
              @response[:vm][:status] = human_status(@response[:vm][:status])
              @response[:vm][:deployed] = @response[:vm][:deployed] == 'true'
            else
              parse_start_element name, attributes, @response[:vm]
            end
          end

          def end_element(name)
            parse_end_element name, @response[:vm]
          end

          def human_status(status)
            case status
            when '-1', -1
              'failed_creation'
            when '0', 0
              'creating'
            when '8', 8
              'off'
            when '4', 4
              'on'
            when '3', 3
              'suspended'
            else
              'unknown'
            end
          end
        end
      end
    end
  end
end
