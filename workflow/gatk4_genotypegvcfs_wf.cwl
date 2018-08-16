---
cwlVersion: v1.0
class: Workflow
id: gatk4-genotypegvcfs-wf
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
inputs:
  scatter_intervals:
    type: File
  gvcf_divide_intervals:
    type: File?
  ref_fasta:
    type: File
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-V"
  dbsnp_vcf:
    type: File
outputs:
  sites_only_vcf:
    outputSource:
    - gather_gvcfs_1/output
    type: File
  placeholder:
    outputSource:
    - vcf_keeper/output
    type: File?
  variant_filtered_vcf:
    outputSource:
    - gather_gvcfs/output
    type: File
steps:
  select_bed_v2:
    in:
    - id: gvcf
      source:
      - input_vcfs
    - id: bed_files
      source:
      - sbg_prepare_intervals/intervals
    out:
    - id: output_bed_file
    run: "../tools/select_bed_v2.cwl"
    label: select bed v2
    hints:
    - class: sbg:useSbgFS
      value: 'true'
  vcf_keeper:
    in:
    - id: input
      linkMerge: merge_flattened
      source:
      - input_vcfs
      - gather_gvcfs/output
    out:
    - id: output
    run: "../tools/vcf_keeper.cwl"
    label: vcf_keeper
  create_vcf_list:
    in:
    - id: input_vcfs
      source:
      - input_vcfs
    out:
    - id: vcf_list
    run: "../tools/create_vcf_list.cwl"
    label: create_vcf_list
  gatk_import_genotype_filtergvcf_merge:
    in:
    - id: interval
      source: dynamicallycombineintervals_1/out_intervals
    - id: ref_fasta
      source: ref_fasta
    - id: dbsnp_vcf
      source: dbsnp_vcf
    - id: input_vcfs_list
      source: create_vcf_list/vcf_list
    out:
    - id: variant_filtered_vcf
    - id: sites_only_vcf
    run: "../tools/gatk_import_genotype_filtergvcf_merge.cwl"
    label: gatk_import_genotype_filtergvcf_merge
    scatter:
    - interval
  dynamicallycombineintervals_1:
    in:
    - id: interval
      source: bedtools_intersect/output_file
    - id: input_vcfs
      source:
      - input_vcfs
    out:
    - id: out_intervals
    run: "../tools/script_dynamicallycombineintervals.cwl"
    label: dynamicallycombineintervals
  gather_gvcfs:
    in:
    - id: input_vcfs
      source:
      - gatk_import_genotype_filtergvcf_merge/variant_filtered_vcf
    out:
    - id: output
    run: "../tools/gather_gvcfs.cwl"
    label: gather_gvcfs
  sbg_prepare_intervals:
    in:
    - id: bed_file
      source: gvcf_divide_intervals
    - id: split_mode
      default: File per interval
    out:
    - id: intervals
    run: "../tools/sbg_prepare_intervals.cwl"
    label: SBG Prepare Intervals
  bedtools_intersect:
    in:
    - id: input_files_b
      source:
      - select_bed_v2/output_bed_file
    - id: input_file_a
      source: scatter_intervals
    out:
    - id: output_file
    run: "../tools/bedtools_intersect.cwl"
    label: BEDTools Intersect
  gather_gvcfs_1:
    in:
    - id: input_vcfs
      source:
      - gatk_import_genotype_filtergvcf_merge/sites_only_vcf
    out:
    - id: output
    run: "../tools/gather_gvcfs.cwl"
    label: gather_gvcfs
hints:
- class: sbg:maxNumberOfParallelInstances
  value: '1'
- class: sbg:AWSInstanceType
  value: r4.4xlarge;ebs-gp2;2048
