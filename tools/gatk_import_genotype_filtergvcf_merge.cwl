cwlVersion: v1.0
class: CommandLineTool
id: gatk_import_genotype_filtergvcf_merge
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: 16000
  coresMin: 1
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/bogdang/gatk-picard:4.0.3
- class: InlineJavascriptRequirement
baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: >- 
    /gatk --java-options "-Xms4g" GenomicsDBImport --genomicsdb-workspace-path
    genomicsdb --batch-size 50 -L $(inputs.interval.path) --reader-threads 16 -ip
    5
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: |-
    && tar -cf genomicsdb.tar genomicsdb
    /gatk --java-options "-Xmx16g -Xms5g" GenotypeGVCFs -R $(inputs.ref_fasta.path) -O output.vcf.gz -D $(inputs.dbsnp_vcf.path) -G StandardAnnotation --only-output-calls-starting-in-intervals -new-qual -V gendb://genomicsdb -L $(inputs.interval.path)
    /gatk --java-options "-Xmx3g -Xms3g"  VariantFiltration  --filter-expression "ExcessHet > 54.69" --filter-name ExcessHet -O $(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz -V output.vcf.gz
    java -Xmx3g -Xms3g -jar /picard.jar MakeSitesOnlyVcf INPUT=$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz OUTPUT=$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).sites_only.variant_filtered.vcf.gz
- position: 1
  prefix: ''
  separate: false
  shellQuote: false
  valueFrom: |-
    ${
        return "$(cat " + inputs.input_vcfs_list.path + ")"
    }
inputs:
  input_vcfs_list:
    type: File
  interval:
    type: File
  ref_fasta:
    type: File
    secondaryFiles:
    - "^.dict"
    - ".fai"
  dbsnp_vcf:
    type: File
    secondaryFiles:
    - ".idx"
outputs:
  variant_filtered_vcf:
    type: File
    outputBinding:
      glob: "$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz"
    secondaryFiles:
    - ".tbi"
  sites_only_vcf:
    type: File
    outputBinding:
      glob: "$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).sites_only.variant_filtered.vcf.gz"
    secondaryFiles:
    - ".tbi"