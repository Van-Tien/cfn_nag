require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupIngressPortRangeRule < BaseRule
  def rule_text
    'Security Groups found ingress with port range instead of just a single port'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W27'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was targeted against inline ingress only
  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      violating_ingresses = security_group.ingresses.reject do |ingress|
        ingress.fromPort == ingress.toPort
      end

      logical_resource_ids << security_group.logical_resource_id unless violating_ingresses.empty?
    end

    violating_ingresses = cfn_model.standalone_ingress.reject do |standalone_ingress|
      standalone_ingress.fromPort == standalone_ingress.toPort
    end

    logical_resource_ids + violating_ingresses.map(&:logical_resource_id)
  end
end
