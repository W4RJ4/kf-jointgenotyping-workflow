class: CommandLineTool
cwlVersion: v1.0
id: gatk_gathertranches
baseCommand:
  - /gatk-launch
inputs:
  - id: input_fofn
    type: 'File[]'
    inputBinding:
      position: 0
      prefix: '--input'
  - id: output_filename
    type: string
    inputBinding:
      position: 0
      prefix: '--output'
outputs:
  - id: tranches
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
label: gatk_gathertranches
arguments:
  - position: 0
    prefix: '--javaOptions'
    valueFrom: '"-Xmx6g -Xms6g"'
  - position: 0
    prefix: GatherTranches
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc:gatk:4.0.1.0'
'sbg:job':
  inputs:
    input_fofn: []
    output_filename: null
    input_1: input_1-string-value
    input_file:
      - class: File
        contents: file contents
        path: /path/to/input_file-1.ext
        secondaryFiles: []
        size: 0
      - class: File
        contents: file contents
        path: /path/to/input_file-2.ext
        secondaryFiles: []
        size: 0
  runtime:
    cores: 1
    ram: 1000
