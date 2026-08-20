connection: "production-lakehouse"

# include all the views
include: "/views/**/*.view.lkml"

datagroup: quantum_dashboards_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: quantum_dashboards_default_datagroup

# For Q1-only tiles

explore: v_quantum1_volume {
  label: "Quantum 1"
}

# For Q2-only tiles
explore: v_quantum2_volume {
  label: "Quantum 2"
}

# For side-by-side comparison tiles only
explore: quantum_combined {
  label: "Quantum 1 & 2 Combined"
  from: v_quantum1_volume

  join: v_quantum2_volume {
    type: full_outer
    sql_on:
      ${quantum_combined.measurement_ts_raw} = ${v_quantum2_volume.measurement_ts_raw}
      AND ${quantum_combined.meter_type} = ${v_quantum2_volume.meter_type}
      AND ${quantum_combined.signal_name} = ${v_quantum2_volume.signal_name} ;;
    relationship: one_to_one
  }
}
