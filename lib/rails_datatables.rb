module ActionView
  module Helpers
    def datatable(columns, opts={})
      sort_by = opts[:sort_by] || nil
      additional_data = opts[:additional_data] || {}
      search = opts[:search].present? ? opts[:search].to_s : "true"
      search_label = opts[:search_label] || "Search"
      processing = opts[:processing] || "Processing"
      use_processing = opts[:use_processing].present? ? opts[:use_processing].to_s : "true"
      persist_state = opts[:persist_state].present? ? opts[:persist_state].to_s : "true"
      table_dom_id = opts[:table_dom_id] ? "##{opts[:table_dom_id]}" : ".datatable"
      per_page = opts[:per_page] || opts[:display_length]|| 25
      no_records_message = opts[:no_records_message] || nil
      auto_width = opts[:auto_width].present? ? opts[:auto_width].to_s : "true"
      row_callback = opts[:row_callback] || nil
      jqueryui = opts.key?(:jqueryui) ? opts[:jqueryui].to_s : "false"
      paginate = opts[:paginate].present? ? opts[:pagintate].to_s : "true"
      surl = opts[:surl] || nil
      destroy = opts[:destroy].present? ? opts[:destroy].to_s : "false"
      append = opts[:append] || nil
      ajax_source = opts[:ajax_source] || nil
      server_side = opts[:ajax_source].present?
      jquery_ui = opts[:jquery_ui] || nil
      dom = opts[:dom] || nil

      additional_data_string = ""
      additional_data.each_pair do |name,value|
        additional_data_string = additional_data_string + ", " if !additional_data_string.blank? && value
        additional_data_string = additional_data_string + "{'name': '#{name}', 'value':'#{value}'}" if value
      end

      %Q{
      <script type="text/javascript">
      jQuery(document).ready(function () {
          jQuery('#{table_dom_id}').dataTable({
              "oLanguage": {
                  "sSearch": "#{search_label}",
                  #{"'sUrl': '#{surl}'," if surl}
                  #{"'sZeroRecords': '#{no_records_message}'," if no_records_message}
                  "sProcessing": '#{processing}'
              },
              "bDestroy": #{destroy},
              "bPaginate": #{paginate},
              "sPaginationType": "full_numbers",
              "iDisplayLength": #{per_page},
              "bJQueryUI": #{jqueryui},
              "bProcessing": #{use_processing},
              "bServerSide": #{server_side},
              "bLengthChange": false,
              "bStateSave": #{persist_state},
              "bFilter": #{search},
              "bAutoWidth": #{auto_width},
              #{"'sDom': '#{dom}'," if dom}
              #{"'aaSorting': [#{sort_by}]," if sort_by}
              #{"'sAjaxSource': '#{ajax_source}'," if ajax_source}
              #{"'bJQueryUI': #{jquery_ui}," if jquery_ui}
              "aoColumns": [
                  #{formatted_columns(columns)}
              ],
              #{"'fnRowCallback': function( nRow, aData, iDisplayIndex ) {
                  #{row_callback}
              }," if row_callback}
              "fnServerData": function ( sSource, aoData, fnCallback ) {
                  aoData.push( #{additional_data_string} );
                  jQuery.getJSON( sSource, aoData, function (json) {
                      fnCallback(json);
                  });
              }
          })#{append};
      });
      </script>
      }.html_safe
    end

    private

      def formatted_columns(columns)
        i = 0
        columns.map {|c|
          i += 1
          if c.nil? or c.empty?
            "null"
          else
            searchable = c[:searchable].to_s.present? ? c[:searchable].to_s : "true"
            sortable = c[:sortable].to_s.present? ? c[:sortable].to_s : "true"

            "{
            'sType': '#{c[:type] || "string"}',
            'bSortable':#{sortable},
            'bSearchable':#{searchable},
            #{"'asSorting':#{c[:sorting].inspect}," if c[:sorting]}
            #{"'bVisible':'#{c[:visible]}'," if c[:visible]}
            #{"'iDataSort':#{c[:datasort]}," if c[:datasort]}
            #{"'sClass':'#{c[:class]}'" if c[:class]}
            }"
          end
        }.join(",")
      end
  end      
end

# EOF
