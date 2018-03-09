class: CommandLineTool
cwlVersion: v1.0
id: gatk_snpsvariantrecalibratorcreatemodel
baseCommand:
  - /gatk-launch
inputs:
  - id: sites_only_variant_filtered_vcf
    type: File
    inputBinding:
      position: 2
      prefix: '-V'
    secondaryFiles:
      - .tbi
  - id: recalibration_filename
    type: string
    inputBinding:
      position: 3
      prefix: '-O'
  - id: tranches_filename
    type: string
    inputBinding:
      position: 4
      prefix: '--tranchesFile'
  - id: dbsnp_resource_vcf
    type: File
    inputBinding:
      position: 93
      prefix: '-resource dbsnp,known=true,training=false,truth=false,prior=2:'
      separate: false
    secondaryFiles:
      - .tbi
  - id: recalibration_tranche_values
    type: 'string[]'
  - id: recalibration_annotation_values
    type: 'string[]'
  - id: hapmap_resource_vcf
    type: File
    inputBinding:
      position: 90
      prefix: '-resource hapmap,known=false,training=true,truth=true,prior=15:'
      separate: false
  - id: downsampleFactor
    type: int
    inputBinding:
      position: 13
      prefix: '-sampleEvery'
  - id: model_report_filename
    type: string
    inputBinding:
      position: 14
      prefix: '--output_model'
  - id: omni_resource_vcf
    type: File
    inputBinding:
      position: 94
      prefix: '-resource omni,known=false,training=true,truth=true,prior=12:'
      separate: false
    secondaryFiles:
      - .tbi
  - id: one_thousand_genomes_resource_vcf
    type: File
    inputBinding:
      position: 95
      prefix: '-resource 1000G,known=false,training=true,truth=false,prior=10:'
      separate: false
    secondaryFiles:
      - .tbi
outputs:
  - id: model_report
    type: File
    outputBinding:
      glob: $(inputs.model_report_filename)
    secondaryFiles:
      - .idx
label: gatk_snpsvariantrecalibratorcreatemodel
arguments:
  - position: 0
    prefix: '--javaOptions'
    valueFrom: '"-Xmx100g -Xms100g"'
  - position: 20
    prefix: '-tranche'
    valueFrom: $(inputs.recalibration_tranche_values.join(" -tranche "))
  - position: 21
    prefix: '-an'
    valueFrom: $(inputs.recalibration_annotation_values.join(" -an "))
  - position: 10
    prefix: '-allPoly'
  - position: 11
    prefix: '-mode'
    valueFrom: SNP
  - position: 12
    prefix: '-maxGaussians'
    valueFrom: '6'
  - position: 1
    prefix: VariantRecalibrator
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc:gatk:4.0.1.0'
'sbg:job':
  inputs:
    sites_only_variant_filtered_vcf:
      basename: sites_only_variant_filtered_vcf.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: sites_only_variant_filtered_vcf
      path: /path/to/sites_only_variant_filtered_vcf.ext
      secondaryFiles: []
      size: 0
    recalibration_filename: recalibration_filename-string-value
    tranches_filename: tranches_filename-string-value
    dbsnp_resource_vcf:
      basename: dbsnp_resource_vcf.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: dbsnp_resource_vcf
      path: /path/to/dbsnp_resource_vcf.ext
      secondaryFiles: []
      size: 0
    recalibration_tranche_values:
      - recalibration_tranche_values-string-value-1
      - recalibration_tranche_values-string-value-2
    recalibration_annotation_values:
      - recalibration_annotation_values-string-value-1
      - recalibration_annotation_values-string-value-2
    hapmap_resource_vcf:
      basename: hapmap_resource_vcf.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: hapmap_resource_vcf
      path: /path/to/hapmap_resource_vcf.ext
      secondaryFiles: []
      size: 0
    downsampleFactor: 6
    model_report_filename: model_report_filename-string-value
    omni_resource_vcf:
      basename: input.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: input
      path: /path/to/input.ext
      secondaryFiles: []
      size: 0
    one_thousand_genomes_resource_vcf:
      basename: input.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: input
      path: /path/to/input.ext
      secondaryFiles: []
      size: 0
  runtime:
    cores: 1
    ram: 1000
