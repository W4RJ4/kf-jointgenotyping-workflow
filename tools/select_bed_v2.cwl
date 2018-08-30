---
cwlVersion: v1.0
class: CommandLineTool
id: select-bed-v2
requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: ubuntu:16.04
- class: InlineJavascriptRequirement
baseCommand: []
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    gvcf_interval = inputs.gvcf[0].path.split('/').pop().split('.')[0]\n
    \   \n    for (var i=0; i < inputs.bed_files.length;i++) {\n        var bed_path
    = inputs.bed_files[i].path\n        var bed_name = bed_path.split('/').pop().split('.')[0]\n
    \       if (bed_name == gvcf_interval){\n            specific_bed = bed_path\n
    \           return \"cp \" + specific_bed + \" .\" \n        }\n    }\n}"
inputs:
  bed_files:
    type: File[]?
  gvcf:
    type: File[]?
outputs:
  output_bed_file:
    type: File?
    outputBinding:
      glob: "${\n    gvcf_interval = inputs.gvcf[0].path.split('/').pop().split('.')[0]\n
        \   \n    for (var i=0; i < inputs.bed_files.length;i++) {\n        var bed_path
        = inputs.bed_files[i].path\n        var bed_name = bed_path.split('/').pop().split('.')[0]\n
        \       if (bed_name == gvcf_interval){\n            specific_bed = bed_path.split('/').pop()\n
        \           return specific_bed\n        }\n    }\n}"