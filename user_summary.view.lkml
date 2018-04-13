view: user_summary {
  derived_table: {
    sql: SELECT
        order_items.user_id ,
        COUNT(*) AS count,
        sum(sale_price) AS total_revenue
      FROM public.order_items  AS order_items
      WHERE
        1=1
        AND {% condition special_time_horizon %} order_items.created_at {% endcondition %}
      GROUP BY 1
       ;;
  }

  filter: special_time_horizon {
    type: date
  }


  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.count ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${total_revenue} ;;
    value_format_name: usd
  }


}
