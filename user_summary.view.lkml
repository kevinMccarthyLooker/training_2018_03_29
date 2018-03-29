view: user_summary {
  derived_table: {
    sql: SELECT
        order_items.user_id ,
        COUNT(*) AS count
      FROM public.order_items  AS order_items

      GROUP BY 1
       ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.count ;;
  }



}
