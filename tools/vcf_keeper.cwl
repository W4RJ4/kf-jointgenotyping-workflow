---
cwlVersion: v1.0
class: CommandLineTool
id: vcf_keeper
requirements:
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: ubuntu:16.04
baseCommand:
- echo all done  
inputs:
  input:
    type: File[]?
outputs:
  output:
    type: File?
    outputBinding:
      glob: output
stdout: output