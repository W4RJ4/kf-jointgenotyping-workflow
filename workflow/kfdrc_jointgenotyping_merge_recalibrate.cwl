cwlVersion: v1.0
class: Workflow
id: kfdrc-jointgenotyping-intervals
requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
inputs:
  reference_dict: File
  hapmap_resource_vcf: File
  output_vcf_basename: string
  one_thousand_genomes_resource_vcf: File
  sites_only_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-I"
    label: Sites Only VCFs
  wgs_evaluation_interval_list: File
  omni_resource_vcf: File
  mills_resource_vcf: File
  filtered_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-I"
    label: Variant Filtered VCFs
  dbsnp_vcf: File
  axiomPoly_resource_vcf: File
outputs:
  finalgathervcf:
    outputSource:
    - gatk_finalgathervcf/output
    type: File
  collectvariantcallingmetrics:
    outputSource:
    - picard_collectvariantcallingmetrics/output
    type: File[]
steps:
  gatk_applyrecalibration:
    in:
      input_vcf: filtered_vcfs
      indels_recalibration: gatk_indelsvariantrecalibrator/recalibration
      indels_tranches: gatk_indelsvariantrecalibrator/tranches
      snps_recalibration: gatk_snpsvariantrecalibratorscattered/recalibration
      snps_tranches: gatk_gathertranches/output
    out:
      - id: recalibrated_vcf
    run: "../tools/gatk_applyrecalibration.cwl"
    scatter:
    - input_vcf
    - snps_recalibration
    scatterMethod: dotproduct
    requirements: []
  gatk_snpsvariantrecalibratorscattered:
    in:
      sites_only_variant_filtered_vcf: sites_only_vcfs
      model_report: gatk_snpsvariantrecalibratorcreatemodel/model_report
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
    out:
      - id: recalibration
      - id: tranches
    run: "../tools/gatk_snpsvariantrecalibratorscattered.cwl"
    scatter:
    - sites_only_variant_filtered_vcf
    requirements: []
  gatk_gathervcfs:
    in:
      input_vcfs: sites_only_vcfs
    out:
      - id: output
    run: "../tools/gatk_gathervcfs.cwl"
    requirements: []
  gatk_snpsvariantrecalibratorcreatemodel:
    in:
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
    out:
      - id: model_report
    run: "../tools/gatk_snpsvariantrecalibratorcreatemodel.cwl"
    requirements: []
  gatk_gathertranches:
    in:
      tranches: gatk_snpsvariantrecalibratorscattered/tranches
    out:
      - id: output
    run: "../tools/gatk_gathertranches.cwl"
    requirements: []
  gatk_indelsvariantrecalibrator:
    in:
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      mills_resource_vcf: mills_resource_vcf
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
    out:
      - id: recalibration
      - id: tranches
    run: "../tools/gatk_indelsvariantrecalibrator.cwl"
    requirements: []
  gatk_finalgathervcf:
    in:
      input_vcfs: gatk_applyrecalibration/recalibrated_vcf
      output_vcf_name: output_vcf_basename
    out:
      - id: output
    run: "../tools/gatk_finalgathervcf.cwl"
    requirements: []
  picard_collectvariantcallingmetrics:
    in:
      input_vcf: gatk_finalgathervcf/output
      reference_dict: reference_dict
      final_gvcf_base_name: output_vcf_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out:
      - id: output
    run: "../tools/picard_collectvariantcallingmetrics.cwl"
    requirements: []
hints:
- class: https://sevenbridges.comAWSInstanceType
  value: r4.8xlarge;ebs-gp2;3500
- class: https://sevenbridges.commaxNumberOfParallelInstances
  value: 4