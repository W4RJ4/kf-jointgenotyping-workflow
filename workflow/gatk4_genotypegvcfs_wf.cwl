---
cwlVersion: v1.0
class: Workflow
id: gatk4-genotypegvcfs-wf
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
inputs:
  scatter_intervals: File
  gvcf_divide_intervals: File?
  ref_fasta: File
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-V"
  dbsnp_vcf: File
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
      gvcf: input_vcfs
      bed_files: sbg_prepare_intervals/intervals
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
      input_vcfs: input_vcfs
    out:
      - id: vcf_list
    run: "../tools/create_vcf_list.cwl"
    label: create_vcf_list
  gatk_import_genotype_filtergvcf_merge:
    in:
      interval: dynamicallycombineintervals_1/out_intervals
      ref_fasta: ref_fasta
      dbsnp_vcf: dbsnp_vcf
      input_vcfs_list: create_vcf_list/vcf_list
    out:
      - id: variant_filtered_vcf
      - id: sites_only_vcf
    run: "../tools/gatk_import_genotype_filtergvcf_merge.cwl"
    label: gatk_import_genotype_filtergvcf_merge
    scatter:
    - interval
  dynamicallycombineintervals_1:
    in:
      interval: bedtools_intersect/output_file
      input_vcfs: input_vcfs
    out:
      - id: out_intervals
    run: "../tools/script_dynamicallycombineintervals.cwl"
    label: dynamicallycombineintervals
  gather_gvcfs:
    in:
      input_vcfs: gatk_import_genotype_filtergvcf_merge/variant_filtered_vcf
    out:
      - id: output
    run: "../tools/gather_gvcfs.cwl"
    label: gather_gvcfs
  sbg_prepare_intervals:
    in:
      bed_file: gvcf_divide_intervals
      split_mode: 
        default: File per interval
    out:
      - id: intervals
    run: "../tools/sbg_prepare_intervals.cwl"
    label: SBG Prepare Intervals
  bedtools_intersect:
    in:
      input_files_b: select_bed_v2/output_bed_file
      input_file_a: scatter_intervals
    out:
      - id: output_file
    run: "../tools/bedtools_intersect.cwl"
    label: BEDTools Intersect
  gather_gvcfs_1:
    in:
      input_vcfs: gatk_import_genotype_filtergvcf_merge/sites_only_vcf
    out:
      - id: output
    run: "../tools/gather_gvcfs.cwl"
    label: gather_gvcfs
hints:
- class: sbg:maxNumberOfParallelInstances
  value: '1'
- class: sbg:AWSInstanceType
  value: r4.4xlarge;ebs-gp2;2048