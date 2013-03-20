require "fine_print/engine"
require "fine_print/fine_print_agreement"

module FinePrint
  # Attributes

  # Can be set in initializer only
  ENGINE_OPTIONS = [
    :current_user_method,
    :user_admin_proc,
    :sign_in_path,
    :redirect_path
  ]

  # Can be set in initializer or passed as an option to fine_print_agreement
  AGREEMENT_OPTIONS = [
    :agreement_notice,
    :grace_period,
    :grace_period_on_new_version_only,
    :use_modal_js,
    :use_referers
  ]
  
  (ENGINE_OPTIONS + AGREEMENT_OPTIONS).each do |option|
    mattr_accessor option
  end
  
  def self.configure
    yield self
  end

  def self.get_option(options, name)
    (!options.nil? && !options[name].nil?) ? options[name] : self.send(name)
  end

  def self.require_agreements(controller, names, options)
    user = controller.send current_user_method
    fine_print_dialog_agreements = []
    names.each do |name|
      agreement = Agreement.latest_ready(name)
      next if agreement.nil? || agreement.accepted_by?(user)
      if get_option(options, :use_modal_js)
        fine_print_dialog_agreements << agreement
      else
        if get_option(options, :use_referers)
          controller.session[:fine_print_request_url] = controller.request.url
          controller.session[:fine_print_request_ref] = controller.request.referer
        end
        controller.redirect_to controller.fine_print.agreement_path(agreement),
          :notice => get_option(options, :agreement_notice)
      end
    end
    controller.instance_variable_set(:@fine_print_dialog_agreements, fine_print_dialog_agreements)
    controller.instance_variable_set(:@fine_print_user, user)
    controller.instance_variable_set(:@fine_print_dialog_notice, get_option(options, :agreement_notice))
  end

  def self.is_admin?(user)
    !user.nil? && user_admin_proc.call(user)
  end
end
