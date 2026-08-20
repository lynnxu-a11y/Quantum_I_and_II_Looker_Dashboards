view: v_quantum1_volume {
  sql_table_name: `gold.v_quantum1_volume` ;;

  # ─────────────────────────────────────────
  # DIMENSIONS — Time
  # ─────────────────────────────────────────

  dimension_group: dt {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dt ;;
    label: "Date"
  }

  dimension_group: measurement_ts {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, hour_of_day, day_of_week]
    sql: ${TABLE}.measurement_ts ;;
    label: "Measurement Time (UTC)"
  }

  dimension_group: measurement_ts_local {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, hour_of_day, day_of_week]
    datatype: datetime
    sql: ${TABLE}.measurement_ts_local ;;
    label: "Measurement Time (Local)"
  }

  dimension_group: loaded {
    type: time
    timeframes: [raw, time, date]
    sql: ${TABLE}.loaded_at ;;
    label: "Loaded At"
    hidden: yes
  }

  # ─────────────────────────────────────────
  # DIMENSIONS — Interval
  # ─────────────────────────────────────────

  dimension: start_time {
    type: string
    sql: ${TABLE}.start_time ;;
    label: "Interval Start"
  }

  dimension: end_time {
    type: string
    sql: ${TABLE}.end_time ;;
    label: "Interval End"
  }

  # ─────────────────────────────────────────
  # DIMENSIONS — Site
  # ─────────────────────────────────────────

  dimension: site_id {
    type: string
    sql: ${TABLE}.site_id ;;
    label: "Site ID"
    hidden: yes
  }

  dimension: site_name {
    type: string
    sql: ${TABLE}.site_name ;;
    label: "Site Name"
  }

  # ─────────────────────────────────────────
  # DIMENSIONS — Meter
  # ─────────────────────────────────────────

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meter_id ;;
    label: "Meter ID"
    hidden: yes
  }

  dimension: meter_name {
    type: string
    sql: ${TABLE}.meter_name ;;
    label: "Meter Name"
  }

  dimension: meter_role {
    type: string
    sql: ${TABLE}.meter_role ;;
    label: "Meter Role"
  }

  dimension: meter_type {
    type: string
    sql: ${TABLE}.meter_type ;;
    label: "Meter Type"
  }

  # ─────────────────────────────────────────
  # DIMENSIONS — Signal & Unit
  # ─────────────────────────────────────────

  dimension: signal_name {
    type: string
    sql: ${TABLE}.signal_name ;;
    label: "Signal Name"
  }

  dimension: is_final_signal {
    type: yesno
    sql: ${signal_name} = 'ActiveExportEnergy.Final'
      OR ${signal_name} = 'ActiveImportEnergy.Final' ;;
    label: "Is Final Signal"
    description: "Flags rows where signal is the authoritative .Final reading"
    hidden: yes
  }

  dimension: unit {
    type: string
    sql: ${TABLE}.unit ;;
    label: "Unit"
  }

  dimension: unit_raw {
    type: string
    sql: ${TABLE}.unit_raw ;;
    label: "Unit (Raw)"
    hidden: yes
  }

  # ─────────────────────────────────────────
  # DIMENSIONS — Value
  # ─────────────────────────────────────────

  dimension: value {
    type: number
    sql: ${TABLE}.value ;;
    label: "Raw Value (kWh)"
    description: "Do not use directly in dashboards — use measures below instead"
    hidden: yes
  }

  dimension: value_raw {
    type: number
    sql: ${TABLE}.value_raw ;;
    label: "Value (Unprocessed)"
    hidden: yes
  }

  # ─────────────────────────────────────────
  # MEASURES — General
  # ─────────────────────────────────────────

  measure: count {
    type: count
    label: "Row Count"
    drill_fields: [site_name, meter_name, signal_name, dt_date]
    hidden: yes
  }

  measure: total_value {
    type: sum
    sql: ${value} ;;
    label: "Total Value (kWh)"
    value_format_name: decimal_2
    description: "Raw sum — use only for debugging. Prefer signal-specific measures."
    hidden: yes
  }

  # ─────────────────────────────────────────
  # MEASURES — Solar PV
  # ─────────────────────────────────────────

  measure: total_pv_generation {
    type: sum
    sql: CASE
      WHEN ${meter_type} = 'PV'
      AND ${signal_name} = 'ActiveExportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Total Solar Generation (MWh)"
    description: "Sum of PV ActiveExportEnergy.Final across both PV meters"
    value_format_name: decimal_2
    drill_fields: [meter_name, dt_date, total_pv_generation]
  }

  measure: peak_pv_generation {
    type: max
    sql: CASE
      WHEN ${meter_type} = 'PV'
      AND ${signal_name} = 'ActiveExportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Peak Solar Output (MWh)"
    description: "Highest single interval PV reading"
    value_format_name: decimal_2
  }

  measure: avg_pv_generation {
    type: average
    sql: CASE
      WHEN ${meter_type} = 'PV'
      AND ${signal_name} = 'ActiveExportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Avg Solar Output per Interval (MWh)"
    value_format_name: decimal_2
  }

  measure: total_pv_import {
    type: sum
    sql: CASE
      WHEN ${meter_type} = 'PV'
      AND ${signal_name} = 'ActiveImportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Total PV Import (MWh)"
    description: "Energy absorbed by PV panels — expected to be very small"
    value_format_name: decimal_2
    hidden: yes
  }

  # ─────────────────────────────────────────
  # MEASURES — Battery (BESS)
  # ─────────────────────────────────────────

  measure: total_bess_discharge {
    type: sum
    sql: CASE
      WHEN ${meter_type} = 'BESS'
      AND ${signal_name} = 'ActiveExportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Total Battery Discharge (MWh)"
    description: "Energy released by battery to grid — ActiveExportEnergy.Final"
    value_format_name: decimal_2
    drill_fields: [meter_name, dt_date, total_bess_discharge]
  }

  measure: total_bess_charge {
    type: sum
    sql: CASE
      WHEN ${meter_type} = 'BESS'
      AND ${signal_name} = 'ActiveImportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Total Battery Charge (MWh)"
    description: "Energy absorbed by battery from PV — ActiveImportEnergy.Final"
    value_format_name: decimal_2
    drill_fields: [meter_name, dt_date, total_bess_charge]
  }

  measure: bess_net_flow {
    type: number
    sql: (${total_bess_discharge} - ${total_bess_charge})/1000 ;;
    label: "Battery Net Flow (MWh)"
    description: "Positive = net discharging, Negative = net charging"
    value_format_name: decimal_2
  }

  measure: bess_efficiency_pct {
    type: number
    sql: SAFE_DIVIDE(
      SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END),
      SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveImportEnergy.Final' THEN ${value} END)
    ) * 100 ;;
    label: "Battery Round-Trip Efficiency (%)"
    description: "Discharge ÷ Charge × 100. Healthy range is 75–90%."
    value_format_name: decimal_1
  }

  measure: peak_bess_discharge {
    type: max
    sql: CASE
      WHEN ${meter_type} = 'BESS'
      AND ${signal_name} = 'ActiveExportEnergy.Final'
      THEN ${value}/1000
    END ;;
    label: "Peak Battery Discharge (MWh)"
    value_format_name: decimal_2
  }

  # ─────────────────────────────────────────
  # MEASURES — Net Export (POI Proxy)
  # ─────────────────────────────────────────

  measure: estimated_net_export {
    type: number
    sql:
      SUM(CASE WHEN ${meter_type} = 'PV'   AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value}/1000 ELSE 0 END)
    + SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value}/1000 ELSE 0 END)
    - SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveImportEnergy.Final' THEN ${value}/1000 ELSE 0 END) ;;
    label: "Est. Net Grid Export (MWh)"
    description: "Proxy for POI: PV Generation + BESS Discharge - BESS Charge. Replace with POI once pipeline is fixed."
    value_format_name: decimal_2
  }

  measure: bess_contribution_pct {
    type: number
    sql: SAFE_DIVIDE(
      SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END),
      SUM(CASE WHEN ${meter_type} = 'PV'   AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END)
        + SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END)
        - SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveImportEnergy.Final' THEN ${value} END)
    ) * 100 ;;
    label: "Battery % of Net Export"
    description: "How much of estimated net export came from battery discharge"
    value_format_name: decimal_1
  }

  measure: pv_contribution_pct {
    type: number
    sql: SAFE_DIVIDE(
      SUM(CASE WHEN ${meter_type} = 'PV' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END),
      SUM(CASE WHEN ${meter_type} = 'PV'   AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END)
        + SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveExportEnergy.Final' THEN ${value} END)
        - SUM(CASE WHEN ${meter_type} = 'BESS' AND ${signal_name} = 'ActiveImportEnergy.Final' THEN ${value} END)
    ) * 100 ;;
    label: "Solar % of Net Export"
    description: "How much of estimated net export came from solar generation"
    value_format_name: decimal_1
  }
}
