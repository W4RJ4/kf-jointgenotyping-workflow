cwlVersion: v1.0
class: CommandLineTool
id: create_vcf_list
requirements:
- class: DockerRequirement
  dockerPull: ubuntu:16.04
- class: InitialWorkDirRequirement
  listing:
  - entryname: "$(inputs.input_vcfs[0].nameroot).txt"
    entry: |-
      ${
          content = ""
          for(i=0;i<inputs.input_vcfs.length;i++){
              content += " -V " + inputs.input_vcfs[i].path
          }
          return content
      }
- class: InlineJavascriptRequirement
baseCommand:
- echo creating list
inputs:
  input_vcfs:
    type: File[]
outputs:
  vcf_list:
    type: File
    outputBinding:
      glob: "*.txt"