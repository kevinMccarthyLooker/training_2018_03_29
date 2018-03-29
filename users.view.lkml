view: users {
  sql_table_name: public.users ;;

#######################
##### Primary Key #####

  dimension: id {
    primary_key: yes
    #hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

########################
##### Contact Info #####
#To do: Create Full Name

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

############################
##### Demographic Info #####
#To do: Create years_as_consumer
#To do: Create age tiers

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

##############################
##### Created Dates Info #####
#To do: Add Quarter Created and Day Of Year Created
  dimension_group: created {
    type: time
    timeframes: [raw,date,month,year]
    sql: ${TABLE}.created_at ;;
  }

#########################
##### Loctaion Info #####
#To do: Add is_domestic yesNo
#To do: Enable mapping: Add Location type field or state map_layer_name

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

######################
##### Other Info #####

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

####################
##### Measures #####

# To do: Create Domestic User Count
  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
  }

}
# To Do: Add group_labels
#Exercise: Add city, state field
#Exercise: Add age tier with groupings 0-17, 18-64, 65 and above
