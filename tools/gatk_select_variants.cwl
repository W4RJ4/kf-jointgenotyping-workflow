---
cwlVersion: v1.0
class: CommandLineTool
id: gatk_4_0_selectvariants
requirements:
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: |-
    ${
        if (inputs.memory_per_job) {
            if (inputs.memory_overhead_per_job) {
                return inputs.memory_per_job + inputs.memory_overhead_per_job
            } else
                return inputs.memory_per_job
        } else if (!inputs.memory_per_job && inputs.memory_overhead_per_job) {
            return 2048 + inputs.memory_overhead_per_job
        } else
            return 2048
    }
  coresMin: 1
- class: DockerRequirement
  dockerImageId: 3c3b8e0ed4e5
  dockerPull: images.sbgenomics.com/teodora_aleksic/gatk:4.0.2.0
- class: InitialWorkDirRequirement
  listing: []
baseCommand: []
arguments:
- position: 0
  shellQuote: false
  valueFrom: "/opt/gatk"
- position: 1
  shellQuote: false
  valueFrom: "--java-options"
- position: 2
  shellQuote: false
  valueFrom: |-
    ${
        if (inputs.memory_per_job) {
            return '\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\"'
        }
        return '\"-Xmx2048M\"'
    }
- position: 3
  shellQuote: false
  valueFrom: SelectVariants
- position: 4
  prefix: "--output"
  shellQuote: false
  valueFrom: |-
    ${
        read_namebase = [].concat(inputs.variant)[0].basename
        bed_name = inputs.intervals_file.nameroot
        return bed_name + '.' + read_namebase
    }
- position: 4
  shellQuote: false
  valueFrom: |-
    ${
        if (inputs.select_expressions) {
            sexpression = inputs.select_expressions
            filter = []
            for (i = 0; i < sexpression.length; i++) {
                filter.push(" --selectExpressions '", sexpression[i], "'")
            }
            return filter.join("").trim()
        }
    }
inputs:
  memory_overhead_per_job:
    type: int?
    label: Memory Overhead Per Job
  intervals_file:
    type: File
    inputBinding:
      position: 4
      prefix: "--intervals"
      shellQuote: false
    label: Intervals File
  reference:
    type: File?
    inputBinding:
      position: 4
      prefix: "--reference"
      shellQuote: false
    label: Reference
    secondaryFiles:
    - ".fai"
    - "^.dict"
  variant:
    type: File
    inputBinding:
      position: 4
      prefix: "--variant"
      shellQuote: false
    label: Variant
    secondaryFiles:
    - ".tbi"
  memory_per_job:
    type: int?
    label: Memory Per Job
outputs:
  select_variants_vcf:
    label: Select Variants VCF
    type: File
    outputBinding:
      glob: "*.vcf.gz"
    secondaryFiles:
    - ".tbi"