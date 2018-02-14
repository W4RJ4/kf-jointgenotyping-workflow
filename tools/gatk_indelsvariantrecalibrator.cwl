class: CommandLineTool
cwlVersion: v1.0
id: gatk_indelsvariantrecalibrator
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
  - id: mills_resource_vcf
    type: File
    inputBinding:
      position: 91
      prefix: '-resource mills,known=false,training=true,truth=true,prior=12:'
      separate: false
    secondaryFiles:
      - .tbi
  - id: axiomPoly_resource_vcf
    type: File
    inputBinding:
      position: 92
      prefix: '-resource axiomPoly,known=false,training=true,truth=false,prior=10:'
      separate: false
    secondaryFiles:
      - .tbi
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
label: gatk_indelsvariantrecalibrator
arguments:
  - position: 0
    prefix: '--javaOptions'
    valueFrom: '"-Xmx24g -Xms24g"'
  - position: 20
    prefix: '-tranche'
    valueFrom: $(inputs.recalibration_tranche_values.join(" -tranche "))
  - position: 21
    prefix: '-an'
    valueFrom: $(inputs.recalibration_annotation_values.join(" -an "))
  - position: 1
    prefix: VariantRecalibrator
  - position: 10
    prefix: '-allPoly'
  - position: 11
    prefix: '-mode'
    valueFrom: INDEL
  - position: 12
    prefix: '--maxGaussians'
    valueFrom: '4'
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc:gatk:4.0.1.0'