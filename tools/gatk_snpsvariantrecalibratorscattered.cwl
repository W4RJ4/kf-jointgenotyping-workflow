class: CommandLineTool
cwlVersion: v1.0
id: gatk_snpsvariantrecalibratorscattered
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
      position: 2
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
    secondaryFiles:
      - .tbi
  - id: model_report
    type: File
    inputBinding:
      position: 5
      prefix: '--input_model'
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
outputs:
  - id: recalibration
    type: File
    outputBinding:
      glob: $(inputs.recalibration_filename)
    secondaryFiles:
      - .idx
  - id: tranches
    type: File
    outputBinding:
      glob: $(inputs.tranches_filename)
label: gatk_snpsvariantrecalibratorscattered
arguments:
  - position: 0
    prefix: '--javaOptions'
    valueFrom: '"-Xmx3g -Xms3g"'
  - position: 20
    prefix: '-tranche'
    valueFrom: $(inputs.recalibration_tranche_values.join(" -tranche "))
  - position: 21
    prefix: '-an'
    valueFrom: $(inputs.recalibration_annotation_values.join(" -an "))
  - position: 10
    prefix: '-allPoly'
  - position: 11
    prefix: '-scatterTranches'
  - position: 12
    prefix: '-mode'
    valueFrom: SNP
  - position: 13
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
    model_report:
      basename: model_report.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: model_report
      path: /path/to/model_report.ext
      secondaryFiles: []
      size: 0
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
