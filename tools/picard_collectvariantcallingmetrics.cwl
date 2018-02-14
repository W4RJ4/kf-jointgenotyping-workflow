class: CommandLineTool
cwlVersion: v1.0
id: picard_collectvariantcallingmetrics
baseCommand:
  - java
  - '-Xmx6g'
  - '-Xms6g'
  - '-jar'
  - /picard.jar
inputs:
  - id: input_vcf
    type: File
    inputBinding:
      position: 10
      prefix: INPUT=
      separate: false
    secondaryFiles:
      - .tbi
  - id: dbsnp_vcf
    type: File
    inputBinding:
      position: 11
      prefix: DBSNP=
      separate: false
    secondaryFiles:
      - .tbi
  - id: ref_dict
    type: File
    inputBinding:
      position: 12
      prefix: SEQUENCE_DICTIONARY=
      separate: false
  - id: metrics_filename_prefix
    type: string
    inputBinding:
      position: 13
      prefix: OUTPUT=
      separate: false
  - id: interval_list
    type: File?
    inputBinding:
      position: 15
      prefix: TARGET_INTERVALS=
      separate: false
outputs:
  - id: detail_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.metrics_filename_prefix).variant_calling_detail_metrics
  - id: summary_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.metrics_filename_prefix).variant_calling_summary_metrics
label: picard_collectvariantcallingmetrics
arguments:
  - position: 14
    prefix: THREAD_COUNT=
    separate: false
    valueFrom: '8'
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
