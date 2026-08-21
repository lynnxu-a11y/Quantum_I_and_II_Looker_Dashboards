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
explore: v_quantum_combined {
  label: "Quantum 1 & 2 Combined"
  description: "Union of Q1 and Q2 — use for all cross-site comparison tiles"
}
