module DataTablesSorts

  def set_sort_direction
    if params[:order].present?
      if params[:order]["0"].present?
        if params[:order]["0"][:dir].present?
          return params[:order]["0"][:dir]
        end
      end
    end
  end

  def apply_sort(collection, sort, cursor, limit, base_model, scopes, order_by)
    if params[:start_on].present? && params[:end_on].present?
      start_on = Date.strptime(params[:start_on], "%m/%d/%Y")
      end_on = Date.strptime(params[:end_on], "%m/%d/%Y")
      custom_date_scope, other_scopes = scopes.partition {|scope| scope == scopes.last}
      custom_date_scope = custom_date_scope.first
    end
    if params[:month_filter] == "true"
      month_scopes, regular_scopes = scopes.partition {|scope| scope =~ /\d/ }
      new_month_scopes = []
      month_scopes.each do |scope|
        begin_params = (scope.index('(')) - 1
        scope = "#{scope[0..begin_params]}"+"(Date.strptime('#{scope.to_date.to_s}', '%d/%m/%Y'))"
        new_month_scopes << scope
      end
    scopes = regular_scopes + new_month_scopes
    end
    if params[:order]["0"][:column].present?
      if scopes.blank?
        if params[:custom_sort].present?
          if sort == "asc"
            if params[:boolean_sort] == "true"
              sorted_collection = "#{base_model.capitalize}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 0 : 1}"
            else
              sorted_collection = "#{base_model.capitalize}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}"
            end
          else
            if params[:boolean_sort] == "true"
              sorted_collection = "#{base_model.capitalize}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 1 : 0}"
            else
              sorted_collection = "#{base_model.capitalize}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}.reverse"
            end
          end
        else
          sorted_collection = "#{base_model.capitalize}.offset(cursor).limit(limit).order_by('#{order_by} #{sort.upcase}')"
        end
      else
        if params[:custom_sort].present?
          if sort == "asc"
            if params[:boolean_sort] == "true"
              if params[:start_on].present? && params[:end_on].present?
                sorted_collection = "#{base_model.capitalize}.#{other_scopes.join(".")}.#{custom_date_scope}(start_on, end_on).offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 0 : 1}"
              else
                sorted_collection = "#{base_model.capitalize}.#{scopes.join(".")}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 0 : 1}"
              end
            else
              if params[:start_on].present? && params[:end_on].present?
                sorted_collection = "#{base_model.capitalize}.#{other_scopes.join(".")}.#{custom_date_scope}(start_on, end_on).offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}"
              else
                sorted_collection = "#{base_model.capitalize}.#{scopes.join(".")}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}"
              end
            end
          else
            if params[:boolean_sort] == "true"
              if params[:start_on].present? && params[:end_on].present?
                sorted_collection = "#{base_model.capitalize}.#{other_scopes.join(".")}.#{custom_date_scope}(start_on, end_on).offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 1 : 0}"
              else
                sorted_collection = "#{base_model.capitalize}.#{scopes.join(".")}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by} ? 1 : 0}"
              end
            else
              if params[:start_on].present? && params[:end_on].present?
                sorted_collection = "#{base_model.capitalize}.#{other_scopes.join(".")}.#{custom_date_scope}(start_on, end_on).offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}.reverse"
              else
                sorted_collection = "#{base_model.capitalize}.#{scopes.join(".")}.offset(cursor).limit(limit).to_a.sort_by{|p| p.#{order_by}}.reverse"
              end
            end
          end
        else
          if params[:start_on].present? && params[:end_on].present?
            sorted_collection = "#{base_model.capitalize}.#{other_scopes.join(".")}.#{custom_date_scope}(start_on, end_on).offset(cursor).limit(limit).order_by('#{order_by} #{sort.upcase}')"
          else
            sorted_collection = "#{base_model.capitalize}.#{scopes.join(".")}.offset(cursor).limit(limit).order_by('#{order_by} #{sort.upcase}')"
          end
        end
      end
      collection = eval(sorted_collection)
      return collection
    end
  end

end
