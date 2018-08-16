cwlVersion: v1.0
class: Workflow
id: gvcf_splitter
requirements:
- class: ScatterFeatureRequirement
inputs:
  bed_file: File
  variant: File
outputs:
  select_variants_vcf:
    outputSource:
    - gatk_4_0_selectvariants/select_variants_vcf
    type: File
steps:
  sbg_prepare_intervals:
    in:
    - bed_file: bed_file
    - id: split_mode
      default: File per interval
    out:
    - id: intervals
    run: "../tools/sbg_prepare_intervals.cwl"
    label: SBG Prepare Intervals
  gatk_4_0_selectvariants:
    in:
    - intervals_file: sbg_prepare_intervals/intervals
    - variant: variant
    out:
    - id: select_variants_vcf
    run: "../tools/gatk_4_0_selectvariants.cwl"
    label: GATK SelectVariants
    scatter:
    - intervals_file
hints:
- class: sbg:AWSInstanceType
  value: m4.10xlarge;ebs-gp2;256