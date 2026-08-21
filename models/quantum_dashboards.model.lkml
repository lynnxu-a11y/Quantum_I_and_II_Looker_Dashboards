connection: "production-lakehouse"

include: "/views/**/*.view.lkml"

datagroup: quantum_dashboards_default_datagroup {
  max_cache_age: "1 hour"
}

persist_with: quantum_dashboards_default_datagroup

# ─────────────────────────────────────────
# Q1 standalone
# ─────────────────────────────────────────
explore: v_quantum1_volume {
  label: "Quantum 1"
  description: "Quantum 1 site — PV and BESS meter data"
}

# ─────────────────────────────────────────
# Q2 standalone
# ─────────────────────────────────────────
explore: v_quantum2_volume {
  label: "Quantum 2"
  description: "Quantum 2 site — PV and BESS meter data"
}

# ─────────────────────────────────────────
# Combined — for cross-site comparison tiles
# ─────────────────────────────────────────
explore: quantum_combined {
  label: "Quantum 1 & 2 Combined"
  description: "Use this Explore for side-by-side Q1 vs Q2 comparisons only"
  from: v_quantum1_volume
  view_name: v_quantum1_volume

  join: v_quantum2_volume {
    type: full_outer
    sql_on:
      ${v_quantum1_volume.measurement_ts_raw} = ${v_quantum2_volume.measurement_ts_raw}
      AND ${v_quantum1_volume.meter_type} = ${v_quantum2_volume.meter_type}
      AND ${v_quantum1_volume.signal_name} = ${v_quantum2_volume.signal_name} ;;
    relationship: one_to_one
  }
}
