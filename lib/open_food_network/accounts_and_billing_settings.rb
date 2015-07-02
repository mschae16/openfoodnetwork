# This class is a lightweight model used to validate preferences for accounts and billing settings
# when they are submitted to the AccountsAndBillingSettingsController

module OpenFoodNetwork
  class AccountsAndBillingSettings
    include ActiveModel::Validations
    attr_accessor :accounts_distributor_id, :collect_billing_information, :create_invoices_for_enterprise_users
    attr_accessor :default_accounts_payment_method_id, :default_accounts_shipping_method_id
    validate :ensure_accounts_distributor_set, unless: lambda { create_invoices_for_enterprise_users == '0' }
    validate :ensure_billing_info_collected, unless: lambda { create_invoices_for_enterprise_users == '0' }
    validate :ensure_default_methods_set, unless: lambda { create_invoices_for_enterprise_users == '0' }

    def initialize(attr)
      attr.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def ensure_accounts_distributor_set
      unless Enterprise.find_by_id(accounts_distributor_id)
        errors.add(:accounts_distributor, "must be set if you wish to create invoices for enterprise users.")
      end
    end

    def ensure_billing_info_collected
      unless collect_billing_information == '1'
        errors.add(:billing_information, "must be collected if you wish to create invoices for enterprise users.")
      end
    end

    def ensure_default_methods_set
      unless Enterprise.find_by_id(accounts_distributor_id) &&
        Enterprise.find_by_id(accounts_distributor_id).payment_methods.find_by_id(default_accounts_payment_method_id)
        errors.add(:default_payment_method, "must be set if you wish to create invoices for enterprise users.")
      end

      unless Enterprise.find_by_id(accounts_distributor_id) &&
        Enterprise.find_by_id(accounts_distributor_id).shipping_methods.find_by_id(default_accounts_shipping_method_id)
        errors.add(:default_shipping_method, "must be set if you wish to create invoices for enterprise users.")
      end
    end
  end
end