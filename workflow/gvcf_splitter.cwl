class: Workflow
cwlVersion: v1.0
id: gvcf_splitter
inputs:
    bed_file: File?
    variant: File
outputs:
  - id: select_variants_vcf
    outputSource:
      - gatk_4_0_selectvariants/select_variants_vcf
    type: File
steps:
  gatk_4_0_selectvariants:
    in:
      intervals_file: sbg_prepare_intervals/intervals
      variant: variant
    out:
      - id: select_variants_vcf
    run: '../tools/gatk_select_variants.cwl'
    label: GATK SelectVariants
    scatter:
      - intervals_file
  sbg_prepare_intervals:
    in:
        bed_file: bed_file
        split_mode: File per interval
    out:
      - id: intervals
    run: '../tools/sbg_prepare_intervals.cwl'
    label: SBG Prepare Intervals
hints:
  - class: 'https://sevenbridges.comAWSInstanceType'
    value: m4.10xlarge;ebs-gp2;256
requirements:
  - class: ScatterFeatureRequirement
