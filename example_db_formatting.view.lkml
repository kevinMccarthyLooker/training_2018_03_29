# view: example_db_formatting {
# ## Time Handling ##
# ## Time Handling ##
#   dimension: ts          { type: date sql: TIMESTAMP(${TABLE}.ts) ;;}
#   dimension: period_type { type: string sql: ${TABLE}.period_type ;;}
#
# ### Categorical Variables ###
#   dimension: geography   { type: string sql: ${TABLE}.geography   ;;}
#   dimension: channel     { type: string sql: ${TABLE}.channel     ;;}
#   dimension: category    { type: string sql: ${TABLE}.category    ;;}
#   dimension: subcategory { type: string sql: ${TABLE}.subcategory ;;}
#
#
#
# ###### In - Database value formatting ######
#   dimension: value_int      {sql: CAST(${TABLE}.value_ AS int64);; hidden: yes}
#   dimension: value_float    {sql: CAST(${TABLE}.
#     AS float64) ;; hidden: yes}
#   dimension: one_billion    {sql: 1000000000 ;; hidden: yes}
#   dimension: one_million    {sql: 1000000 ;; hidden: yes}
#   dimension: one_thousand   {sql: 1000 ;; hidden: yes}
#   dimension: curreny_symbol {sql: '$' /*Can be parameterized in the future*/;; hidden: yes}
#
#   dimension: value_scale {
#     hidden: yes
#     type: string
#     sql:
#      /* What scale/order of magnitude is the value? */
#       CASE
#         WHEN ${value_float} >= ${one_billion}  THEN 'B'
#         WHEN ${value_float} >= ${one_million}  THEN 'M'
#         WHEN ${value_float} >= ${one_thousand} THEN 'K'
#         ELSE ''
#       END
#       ;;
#   }
#
#   dimension: scaled_value {
#     type: number
#     hidden: yes
#     sql:
#       /* Scale the actual value for more readable display */
#       CASE
#         WHEN ${value_scale} = 'B' THEN (${value_float} * 1.0 / ${one_billion})
#         WHEN ${value_scale} = 'M' THEN (${value_float} * 1.0 / ${one_million})
#         WHEN ${value_scale} = 'K' THEN (${value_float} * 1.0 / ${one_thousand})
#         ELSE ${value_float}
#       END
#        ;;
#   }
#
#   #Format codes
#   dimension: fc_dwc   {sql:"%'d" /* digit number with commas */;;            hidden: yes}
#   dimension: fc_pdn   {sql:"%.2f"/* precise decimal number*/;;               hidden: yes}
#   dimension: fc_2pwc  {sql:"%'.2f"/* precise decimal number with commas*/;;  hidden: yes}
#   dimension: fc_perc  {sql:"%.1f"/* percent_1 */;;                           hidden: yes}
#
#   #Formats applied to value_
#   dimension: db_format_whole_number         { sql:FORMAT(${fc_dwc}, ${value_int}) ;;                                                     hidden: yes }
#   dimension: db_format_decimal_number       { sql:FORMAT(${fc_pdn}, ${value_float}) ;;                                                   hidden: yes }
#   dimension: db_format_dollar_value_precise { sql:CONCAT(${curreny_symbol}, FORMAT(${fc_2pwc}, ${value_float}));;                        hidden: yes }
#   dimension: db_format_dollar_value_scaled  { sql:CONCAT(${curreny_symbol}, FORMAT(${fc_2pwc}, ${scaled_value}),' ',${value_scale});;    hidden: yes }
#   dimension: db_format_wn_value_scaled      { sql:CONCAT(FORMAT(${fc_2pwc}, ${scaled_value}),' ',${value_scale});;                       hidden: yes }
#   dimension: db_format_percent              { sql:CONCAT(FORMAT(${fc_perc}, ${value_float}*100),'%');;                                                  hidden: yes }
#
#
#
# ###### END In - Database value formatting ######
#
# #   dimension: measure_length {
# #     hidden: yes
# #     type: number
# #     sql: LENGTH(${TABLE}.measure) ;;
# #   }
# #
# #   dimension: category_length {
# #     hidden: yes
# #     type: number
# #     sql: LENGTH(${TABLE}.category) ;;
# #   }
# #
# #   dimension: root_node_combined_title_length {
# #     type: number
# #     hidden: yes
# #     sql:  ${category_length} + ${measure_length} ;;
# #   }
#
#
#   dimension: measure {
#     # This is the measure or KPI type, it contains special logic so that the "Linked sales only" heirarchy will
#     # display with the category on top
#     label: "Measure Type"
#     type: string
#     sql:
#       {% assign x = is_linked_sales_passthrough._sql %}
#        {% if  x contains "Y"  %}
#           CASE
#            WHEN ${category} IS NULL THEN ${TABLE}.measure
#            WHEN ${id} = 3 THEN concat(${category})
#            ELSE ${TABLE}.measure
#           END
#         {% else %}
#            ${TABLE}.measure
#         {% endif %}
#     ;;
# #   WHEN ${id} = 3 THEN concat(${category}, '-', ${TABLE}.measure)
#
# #     html:
# #         {% if value.size > 15 %}
# #            {{ value | newline_to_br }}
# #         {% else %}
# #          {{ value }}
# #         {% endif %}
# #     ;;
#   }
#
#   measure: value_ {
#     #The literal value of the measure. No aggregation should be taking place since these measures may not be additive
#     #The max is simply to allow sql and looker to treat it as a measure for the purpose of visualization
#     label: "Measure Value"
#     type: string
#     sql:
#       MAX(
#         CASE
#               /* Tree KPIs */
#               WHEN ${TABLE}.measure = 'Total Sales'            THEN ${db_format_dollar_value_scaled}
#               WHEN ${TABLE}.measure = 'Linked Sales'           THEN ${db_format_dollar_value_scaled}
#               WHEN ${TABLE}.measure = 'Non-Linked Sales'       THEN ${db_format_dollar_value_scaled}
#               WHEN ${TABLE}.measure = 'Transactions'           THEN ${db_format_wn_value_scaled}
#               WHEN ${TABLE}.measure = 'Frequency'              THEN ${db_format_decimal_number}
#               WHEN ${TABLE}.measure = 'Average Selling Price'  THEN ${db_format_dollar_value_precise}
#               WHEN ${TABLE}.measure = 'Items Per Basket'       THEN ${db_format_decimal_number}
#               WHEN ${TABLE}.measure = 'Transaction Value'      THEN ${db_format_dollar_value_precise}
#               WHEN ${TABLE}.measure = 'Customers'              THEN ${db_format_whole_number}
#               /* Single-Value KPIs */
#               WHEN LTRIM(${TABLE}.measure) = '% Sales With Discount'                THEN ${db_format_percent}
#               WHEN LTRIM(${TABLE}.measure) = '% Sales On Luxury Brands'             THEN ${db_format_percent}
#               WHEN LTRIM(${TABLE}.measure) = 'Number Of Unique Products Sold'       THEN ${db_format_whole_number}
#               WHEN LTRIM(${TABLE}.measure) = 'Average Discount Level'               THEN ${db_format_percent}
#             ELSE '0'
#         END
#         )
#      ;;
#     html:
#     {% if id._is_selected %}
#     <br>
#     <span style="color: #E7E8E8">-----------------------</span><br>
#     <span style="text-align: right;">{{rendered_value}}  <span style="color: rgba(0,0,0,0);">▲</span> </span> <br>
#     <span style="color: #E7E8E8">-----------------------</span>
#     {% else %}
#     {{rendered_value}}
#     <br/>
#
#     {% endif %}
#     ;;
#
#
# }
# }
