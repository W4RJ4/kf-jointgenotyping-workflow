class: Workflow
cwlVersion: v1.0
id: post_vqsr
label: post-vqsr
inputs: []
outputs: []
steps:
  - id: gatk_applyrecalibration
    in: []
    out:
      - id: recalibrated_vcf
    run: >-
      /Users/dmiller/Documents/CDIS/KidsFirst/kf-jointgenotyping-workflow/tools/gatk_applyrecalibration.cwl
    label: gatk_applyrecalibration
    'sbg:x': 39.6015625
    'sbg:y': 48
  - id: picard_collectvariantcallingmetrics
    in: []
    out:
      - id: detail_metrics_file
      - id: summary_metrics_file
    run: >-
      /Users/dmiller/Documents/CDIS/KidsFirst/kf-jointgenotyping-workflow/tools/picard_collectvariantcallingmetrics.cwl
    label: picard_collectvariantcallingmetrics
    'sbg:x': 375.6015625
    'sbg:y': 46
  - id: gatk_indelsvariantrecalibrator
    in: []
    out:
      - id: recalibration
      - id: tranches
    run: >-
      /Users/dmiller/Documents/CDIS/KidsFirst/kf-jointgenotyping-workflow/tools/gatk_snpsvariantrecalibratorscattered.cwl
    label: gatk_snpsvariantrecalibratorscattered
    'sbg:x': -291.39886474609375
    'sbg:y': 120
  - id: gatk_indelsvariantrecalibrator_1
    in: []
    out:
      - id: model_report
    run: >-
      /Users/dmiller/Documents/CDIS/KidsFirst/kf-jointgenotyping-workflow/tools/gatk_snpsvariantrecalibratorcreatemodel.cwl
    label: gatk_snpsvariantrecalibratorcreatemodel
    'sbg:x': -225.98876953125
    'sbg:y': -115.71621704101562
