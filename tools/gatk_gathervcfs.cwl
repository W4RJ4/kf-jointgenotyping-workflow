cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathergvcfs
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
  shellQuote: false
  valueFrom: /gatk/gatk-launch --javaOptions "-Xmx6g -Xms6g" GatherVcfsCloud --ignoreSafetyChecks
    --gatherType BLOCK --output sites_only.vcf.gz
- position: 2
  shellQuote: false
  valueFrom: '&& /tabix/tabix sites_only.vcf.gz'
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 1
outputs:
  output:
    type: File
    outputBinding:
      glob: sites_only.vcf.gz
    secondaryFiles:
    - .tbi