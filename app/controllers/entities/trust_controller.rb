class Entities::TrustController < ApplicationController

  before_action :current_page
  before_action :check_xhr_page, only: [:contact_info, :owns]
  before_action :set_entity, only: [:basic_info]
  
  def basic_info
    #key = params[:entity_key]
    if request.get?
      #@entity = Entity.find_by(key: key)
      entity_check() if @entity.present?
      @entity       ||= Entity.new(type_: params[:type])
      @just_created = params[:just_created].to_b    
      if @entity.name == ""
        individual_breadcrumb
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust"
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "edit"
        add_breadcrumb "Basic info", '', :title => "Basic info"
      end
    elsif request.post?
      @entity                 = Entity.new(entity_params)
      @entity.type_           = MemberType.getTrustId
      @entity.basic_info_only = true
      @entity.user_id         = current_user.id
      if @entity.save
        AccessResource.add_access({ user: current_user, resource: @entity })
        flash[:success] = "Congratulations, you have just created a record for #{@entity.name}"
        return redirect_to entities_trust_basic_info_path( @entity.key )
      else
        individual_breadcrumb
      end
    elsif request.patch?
      #@entity                 = Entity.find_by(key: key)
      prior_entity_name = @entity.name
      @entity.type_           = MemberType.getTrustId
      @entity.basic_info_only = true
      if @entity.update(entity_params)
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_entity_name}"
        return redirect_to edit_entity_path(@entity.key)
      end
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  def individual_breadcrumb
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Trust", '',  :title => "Trust"
    add_breadcrumb "Create", '',  :title => "Create"
  end

  def contact_info
    @entity = Entity.find_by(key: params[:entity_key])
    raise ActiveRecord::RecordNotFound if @entity.blank?
    if request.get?
      #TODO
      add_breadcrumb "Clients", clients_path, :title => "Clients" 
      add_breadcrumb "Trust", '',  :title => "Trust"
      add_breadcrumb "Edit: #{@entity.name}", '',  :title => "edit"
      add_breadcrumb "Contact info", '', :title => "Contact info"
    elsif request.patch?
      @entity.basic_info_only = false
      @entity.update(entity_params)
      add_breadcrumb "Clients", clients_path, :title => "Clients" 
      add_breadcrumb "Trust", '',  :title => "Trust"
      add_breadcrumb "Edit: #{@entity.name}", '',  :title => "edit"
      add_breadcrumb "Contact info", '', :title => "Contact info"
      return render layout: false, template: "entities/trust/contact_info"
    else
      raise UnknownRequestFormat
    end
    render layout: false if request.xhr?
  end

  def settlor
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @settlor                 = Settlor.find(id) if id.present?
      @settlor                 ||= Settlor.new
      @settlor.super_entity_id = @entity.id
    end
    if request.get?
      if @settlor.new_record?
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
        add_breadcrumb "Settlor Create", '',  :title => "Settlor Create"
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit" 
        add_breadcrumb "Settlor", '',  :title => "Settlor"
        # add_breadcrumb "Show in list", clients_path(active_id: @entity.id), :title => "show", :id => "show_in_list"
      end
    elsif request.post?
      @settlor                 = Settlor.new(settlor_params)
      @settlor.use_temp_id
      @settlor.super_entity_id = @entity.id
      @settlor.class_name      = "Settlor"
      if @settlor.save
        @settlors = @settlor.super_entity.settlors
        flash[:success] = "Congratulations, you have just created a record for #{@settlor.first_name} #{@settlor.last_name}, a Settlor of #{@entity.name}"
        return redirect_to entities_trust_settlor_path(@entity.key, @settlor.id)
      else
        # return render layout: false, template: "entities/trust/settlor"
        return redirect_to entities_trust_settlor_path(@entity.key, @settlor.id)
      end
    elsif request.patch?
      prior_settlor_name = "#{@settlor.first_name} #{@settlor.last_name}"
      if @settlor.update(settlor_params)
        @settlor.use_temp_id
        @settlor.save
        @settlors = @settlor.super_entity.settlors
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_settlor_name}, a Settlor of #{@entity.name}"
        return redirect_to entities_trust_settlor_path(@entity.key, @settlor.id)
      else
        # return render layout: false, template: "entities/trust/settlor"
        return redirect_to entities_trust_settlor_path(@entity.key, @settlor.id)
      end
    elsif request.delete?
      settlor = Settlor.find(params[:id])
      @entity = settlor.super_entity
      settlor.delete
      @settlors = settlor.super_entity.settlors
      flash[:success] = "The Settlor Successfully Deleted."
      return redirect_to entities_trust_settlors_path(@entity.key)
    end
    @settlor.gen_temp_id
    render layout: false if request.xhr?
  end

  def settlors
    @entity = Entity.find_by(key: params[:entity_key])
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Trust", '',  :title => "Trust" 
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
    add_breadcrumb "Settlors", '',  :title => "Settlors"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @settlors = @entity.settlors
    @activeId = params[:active_id]
    render layout: false if request.xhr?
  end

  def trustee
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @trustee                 = Trustee.find(id) if id.present?
      @trustee                 ||= Trustee.new
      @trustee.super_entity_id = @entity.id
      @trustee.class_name      = "Trustee"
    end
    if request.get?
      if @trustee.new_record?
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
        add_breadcrumb "Trustee Create", '',  :title => "Trustee Create"
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit" 
        add_breadcrumb "Trustee", '',  :title => "Trustee"
        # add_breadcrumb "Show in list", clients_path(active_id: @entity.id), :title => "show", :id => "show_in_list"
      end

    elsif request.post?
      @trustee                 = Trustee.new(trustee_params)
      @trustee.use_temp_id
      @trustee.super_entity_id = @entity.id
      if @trustee.save
        @trustees = @trustee.super_entity.trustees
        flash[:success] = "Congratulations, you have just created a record for #{@trustee.first_name} #{@trustee.last_name}, a Trustee of #{@entity.name}"
        return redirect_to entities_trust_trustee_path(@entity.key, @trustee.id)
      else
        # return render layout: false, template: "entities/trust/trustee"
        return redirect_to entities_trust_trustee_path(@entity.key, @trustee.id)
      end
    elsif request.patch?
      prior_trustee_name = "#{@trustee.first_name} #{@trustee.last_name}"
      if @trustee.update(trustee_params)
        @trustees = @trustee.super_entity.trustees
        @trustee.use_temp_id
        @trustee.save
        # return render layout: false, template: "entities/trust/trustees"
        flash[:success] = "Congratulations, you have just made a change in the record for #{prior_trustee_name}, a Trustee of #{@entity.name}"
        return redirect_to entities_trust_trustee_path(@entity.key, @trustee.id)
      else
        # return render layout: false, template: "entities/trust/trustee"
        return redirect_to entities_trust_trustee_path(@entity.key, @trustee.id)
      end
    elsif request.delete?
      trustee = Trustee.find(params[:id])
      @entity = trustee.super_entity
      trustee.delete
      @trustees = trustee.super_entity.trustees
      # return render layout: false, template: "entities/trust/trustees"
      flash[:success] = "The Trustee Successfully Deleted."
      return redirect_to entities_trust_trustees_path(@entity.key)
    end
    @trustee.gen_temp_id
    render layout: false if request.xhr?
  end

  def trustees
    @entity = Entity.find_by(key: params[:entity_key])
    add_breadcrumb "Clients", clients_path, :title => "Clients"
    add_breadcrumb "Trust", '',  :title => "Trust"
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
    add_breadcrumb "Trustees", '',  :title => "Trustees"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @trustees = @entity.trustees
    @activeId = params[:active_id]
    render layout: false if request.xhr?
  end

  def beneficiary
    unless request.delete?
      @entity = Entity.find_by(key: params[:entity_key])
      id      = params[:id]
      raise ActiveRecord::RecordNotFound if @entity.blank?
      @beneficiary                 = Beneficiary.find(id) if id.present?
      @beneficiary                 ||= Beneficiary.new
      @beneficiary.super_entity_id = @entity.id
      @beneficiary.class_name      = "Beneficiary"
    end
    if request.get?
      if @beneficiary.new_record?
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit" 
        add_breadcrumb "Beneficiary Create", '',  :title => "Beneficiary Create"
      else
        add_breadcrumb "Clients", clients_path, :title => "Clients" 
        add_breadcrumb "Trust", '',  :title => "Trust" 
        add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit" 
        add_breadcrumb "Beneficiary", '',  :title => "Beneficiary"
        # add_breadcrumb "Show in list", clients_path(active_id: @entity.id), :title => "show", :id => "show_in_list"
      end
    elsif request.post?
      @beneficiary                 = Beneficiary.new(beneficiary_params)
      @beneficiary.use_temp_id
      @beneficiary.super_entity_id = @entity.id
      if @beneficiary.save
        @beneficiaries = @beneficiary.super_entity.beneficiaries
        # return render layout: false, template: "entities/trust/beneficiaries"
        flash[:success] = "Congratulations, you have just created a record for #{@beneficiary.first_name} #{@beneficiary.last_name}, a Beneficiary of #{@entity.name}"
        return redirect_to entities_trust_beneficiary_path(@entity.key, @beneficiary.id)
      else
        # return render layout: false, template: "entities/trust/beneficiary"
        return redirect_to entities_trust_beneficiary_path(@entity.key, @beneficiary.id)
      end
    elsif request.patch?
      prior_beneficiary_name = "#{@beneficiary.first_name} #{@beneficiary.last_name}"
      if @beneficiary.update(beneficiary_params)
        @beneficiary.use_temp_id
        @beneficiary.save
        @beneficiaries = @beneficiary.super_entity.beneficiaries
        # return render layout: false, template: "entities/trust/beneficiaries"
        flash[:success] = "Congratulations, you have just created a record for #{prior_beneficiary_name}, a Beneficiary of #{@entity.name}"
        return redirect_to entities_trust_beneficiary_path(@entity.key, @beneficiary.id)
      else
        # return render layout: false, template: "entities/trust/beneficiary"
        return redirect_to entities_trust_beneficiary_path(@entity.key, @beneficiary.id)
      end
    elsif request.delete?
      beneficiary = Beneficiary.find(params[:id])
      @entity     = beneficiary.super_entity
      beneficiary.delete
      @beneficiaries = beneficiary.super_entity.beneficiaries
      # return render layout: false, template: "entities/trust/beneficiaries"
      flash[:success] = "The Beneficiary Successfully Deleted."
      return redirect_to entities_trust_beneficiaries_path(@entity.key)
    end
    @beneficiary.gen_temp_id
    render layout: false if request.xhr?
  end

  def beneficiaries
    @entity = Entity.find_by(key: params[:entity_key])
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Trust", '',  :title => "Trust" 
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
    add_breadcrumb "Beneficiaries", '',  :title => "Beneficiaries"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    @beneficiaries = @entity.beneficiaries
    @activeId = params[:active_id]
    render layout: false if request.xhr?
  end

  def owns
    @entity = Entity.find_by(key: params[:entity_key])
    @ownership_ = @entity.build_ownership_tree_json
    @owns_available = (@ownership_[0][:nodes] == nil) ? false : true
    @ownership = @ownership_.to_json
    add_breadcrumb "Clients", clients_path, :title => "Clients" 
    add_breadcrumb "Trust", '',  :title => "Trust" 
    add_breadcrumb "Edit: #{@entity.name}", '',  :title => "Edit"
    add_breadcrumb "Owns", '',  :title => "Owns"
    
    raise ActiveRecord::RecordNotFound if @entity.blank?
    render layout: false if request.xhr?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private
  def entity_params
    params.require(:entity).permit(:name, :address, :type_, :jurisdiction, :number_of_assets,
                                   :first_name, :last_name, :phone1, :phone2, :fax, :email,
                                   :postal_address, :city, :state, :zip, :date_of_formation, :m_date_of_formation,
                                   :ein_or_ssn, :s_corp_status, :not_for_profit_status, :legal_ending, :honorific, :is_honorific)
  end

  def settlor_params
    params.require(:settlor).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                    :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                    :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def beneficiary_params
    params.require(:beneficiary).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                        :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                        :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def trustee_params
    params.require(:trustee).permit(:temp_id, :member_type_id, :is_person, :entity_id, :first_name, :last_name, :phone1, :phone2,
                                    :fax, :email, :postal_address, :city, :state, :zip, :ein_or_ssn,
                                    :stock_share, :notes, :honorific, :is_honorific, :my_percentage, :tax_member, :contact_id)
  end

  def current_page
    @current_page = "entity"
  end

  def check_xhr_page
    unless request.xhr?
      if params[:action] != "basic_info"
        return redirect_to entities_trust_basic_info_path(params[:entity_key], xhr: request.env["REQUEST_PATH"])
      end
    end
  end

  def set_entity
    key = params[:entity_key]
    @entity = Entity.find_by(key: key)
  end
end
