require 'json'


module Json2htmltable

  def self.create_table(html)
    output =  "<table class='primary'><thead><tr>"
    if html.is_a?(Array)
      html[0].keys.map do |table_head|
        table_head = Rack::Utils.escape_html(table_head)
        output += "<th>#{table_head}</th>"
      end
    else
      html.keys.map do |table_head|
        table_head = Rack::Utils.escape_html(table_head)
        output += "<th>#{table_head}</th>"
      end
    end

    output += "</tr></thead><tbody><tr>"
    if html.is_a?(Array)
      html.each do | htmlrow |
        htmlrow.values.map  do |table_row|
          if table_row.is_a?(Hash)
            create_table(table_row)
          else
            table_row = Rack::Utils.escape_html(table_row)
            output += "<td>#{table_row}</td>"
          end
        end
        output += "</tr>"
      end
      output += "</tbody></table>"
    else
      html.values.map  do |table_row|
        if table_row.is_a?(Hash)
          create_table(table_row)
        else
          table_row = Rack::Utils.escape_html(table_row)
          output += "<td>#{table_row}</td>"
        end
      end
      output += "</tr></tbody></table>"
    end
    return output
  end
end
