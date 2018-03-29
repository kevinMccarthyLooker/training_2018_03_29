connection: "events_ecommerce"

include: "*.view" # include all the views

include: "*.dashboard" # include all the dashboards

datagroup: training_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_default_datagroup

explore: users {}

explore: order_items {
  label: "things I ordered"
  #To Do: Add distribution_centers join to this explore
  description: "Information about orders including user information"
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_summary {
    view_label: "Users"
    type: left_outer
    sql_on: ${order_items.user_id}=${user_summary.user_id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on:   ${inventory_items.id}=${order_items.inventory_item_id};;
    relationship: many_to_one
  }
}

# explore: order_items2 {
#   from: order_items
# }
