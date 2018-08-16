cwlVersion: v1.0
class: CommandLineTool
id: gather_gvcfs
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: 10000
  coresMin: 5
- class: DockerRequirement
  dockerPull: kfdrc/gatk:4.beta.6-tabix-m
- class: InlineJavascriptRequirement
baseCommand: []
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: /gatk/gatk-launch --javaOptions "-Xmx6g -Xms6g" GatherVcfsCloud --ignoreSafetyChecks
    --gatherType BLOCK --output $(inputs.input_vcfs[0].basename)
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: "&& /tabix/tabix $(inputs.input_vcfs[0].basename)"
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: "-I"
    inputBinding:
      position: 1
outputs:
  output:
    type: File
    outputBinding:
      glob: "$(inputs.input_vcfs[0].basename)"
    secondaryFiles:
    - ".tbi"