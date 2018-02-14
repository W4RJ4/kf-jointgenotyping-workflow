class: CommandLineTool
cwlVersion: v1.0
id: picard_gathermetrics
baseCommand:
  - java
  - '-Xmx2g'
  - '-Xms2g'
  - '-jar'
  - /picard.jar
  - AccumulateVariantCallingMetrics
inputs:
  - id: input
    type:
      - File
      - type: array
        items: File
  - id: output_prefix
    type: string
    inputBinding:
      position: 0
      prefix: '-O='
      separate: false
outputs:
  - id: detail_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_detail_metrics
  - id: summary_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_summary_metrics
label: picard_gathermetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
'sbg:job':
  inputs:
    output_prefix: output_prefix-string-value
    input:
      path: /path/to/input.ext
      class: File
      size: 0
      contents: file contents
      secondaryFiles: []
      basename: input.ext
      nameroot: input
      nameext: .ext
  runtime:
    cores: 1
    ram: 1000
