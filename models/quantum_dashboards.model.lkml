connection: "production-lakehouse"

# include all the views
include: "/views/**/*.view.lkml"

datagroup: quantum_dashboards_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: quantum_dashboards_default_datagroup

explore: v_quantum1_volume {
  label: "Quantum 1 & 2 Combined"

  join: v_quantum2_volume {
    type: full_outer
    sql_on:
      ${v_quantum1_volume.measurement_ts_raw} = ${v_quantum2_volume.measurement_ts_raw}
      AND ${v_quantum1_volume.signal_name} = ${v_quantum2_volume.signal_name} ;;
    relationship: one_to_one
  }
}
