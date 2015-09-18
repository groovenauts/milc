# coding: utf-8

require "milc/gcloud"

require "yaml"
require "json"

require 'active_support/core_ext/string/inflections'

module Milc
  module Gcloud
    class Resource
      class << self
        def command_defs
          @command_defs ||= YAML.load_file(File.expand_path("../commands.yml", __FILE__))
        end

        def command_def_for(service, resource)
          c = command_defs
          s = c[service.to_s] or raise "service #{service.inspect} not found in #{c.keys.join(', ')}"
          s[resource.to_s] or raise "resource #{resource.inspect} not found in #{s.keys.join(' ')} of #{service.inspect}"
        end

        def lookup(project, service, resource)
          Milc.logger.debug("=" * 100)
          Milc.logger.debug("project: #{project}, service: #{service}, resource: #{resource}")
          service = service.to_s
          resource = resource.to_s
          command_def = command_def_for(service, resource)
          result = new(project, service, resource, command_def['commands'])
          service_module = Milc::Gcloud.const_get(service.classify)
          m = resource.gsub(/-/, '_').camelize.to_sym
          if service_module.constants.include?(m)
            resource_module = service_module.const_get(m)
            Milc.logger.debug("#{m} found as #{resource_module.inspect}")

            result.extend(resource_module)
          else
            Milc.logger.debug("#{m} not found in #{service_module.constants.inspect}")
          end
          result
        end
      end

      attr_reader :project, :service, :resource, :commands
      def initialize(project, service, resource, commands)
        @project, @service, @resource = project, service, resource
        @commands = commands || []
      end

      def __gcloud(cmd, options = {}, &block)
        c = "gcloud #{cmd} --format json"
        c << " --project #{project}" unless c =~ /\s\-\-project[\s\=]/
        res = Gcloud.backend.execute(c, options, &block)
        res ? JSON.parse(res) : nil
      end

      def build_attr_arg(attr_name, value)
        "--#{attr_name.to_s.gsub(/\_/, '-')} #{value}"
      end

      def build_attr_args(attrs)
        attrs.map{|k,v| build_attr_arg(k,v) }.join(" ")
      end

      def build_sub_attr_args(attrs)
        attrs.map{|k,v| "#{k.to_s.gsub(/\_/, '-')}=#{v}" }.join(",")
      end

      def call_action(action, cmd_args, attrs = nil, &block)
        attr_args = attrs.nil? ? '' : build_attr_args(attrs)
        options =
          action =~ /\Alist|\Adescribe|\Aget/ ?
            {returns: :stdout, logging: :stderr} :
            {returns: :none  , logging: :both}
        __gcloud("#{service} #{resource} #{action} #{cmd_args} #{attr_args}", options, &block)
      end

      def call_update(cmd_args, attrs, &block)
        call_action(:update, cmd_args, attrs, &block)
      end

      def find(name)
        r = call_action(:list, name)
        r ? r.first : nil
      end

      def raise_if_invalid(command)
        return if commands.include?(command.to_s)
        raise NotImplementedError, "#{service} #{resource} #{command} is not supported."
      end

      def normalize_keys(obj)
        case obj
        when Array then obj.map{|o| normalize_keys(o) }
        when Hash  then
          obj.each_with_object({}) do |(k,v), d|
            d[k.to_s.underscore.to_sym] = normalize_keys(v)
          end
        else
          obj
        end
      end

      def compare(attrs, res)
        Milc.logger.debug("compare\n  attrs: #{attrs.inspect}\n   res: #{res.inspect}")
        res = normalize_keys(res)
        attrs.all?{|k,v| res[k.to_s.gsub(/-/, '_').to_sym] == v }
      end

      def split_sort(str, spliter = /\s+/, &block)
        return nil unless str
        str.split(spliter).sort(&block)
      end

      def create(cmd_args, attrs, &block)
        raise_if_invalid(:create)
        name, args = *cmd_args.split(/\s+/, 2)
        r = find(name)
        if r
          return r unless commands.include?('update')
          if compare(attrs, r)
            return r
          else
            return call_update(cmd_args, attrs, &block)
          end
        else
          call_action(:create, cmd_args, attrs, &block)
        end
      end

      def update(cmd_args, attrs, &block)
        raise_if_invalid(:update)
        name, args = *cmd_args.split(/\s+/, 2)
        r = find(name)
        raise "Resource not found #{service} #{resource} #{name}" unless r
        return r if compare(attrs, r)
        call_update(cmd_args, attrs, &block)
      end

      def delete(cmd_args, attrs = {}, &block)
        raise_if_invalid(:delete)
        name, args = *cmd_args.split(/\s+/, 2)
        r = find(name)
        return nil unless r
        call_action(:delete, cmd_args, attrs, &block)
      end
    end
  end
end
