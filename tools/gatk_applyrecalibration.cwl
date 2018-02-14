class: CommandLineTool
cwlVersion: v1.0
id: gatk_applyrecalibration
baseCommand:
  - set
  - '-e'
inputs:
  - id: recalibrated_vcf_filename
    type: string
  - id: input_vcf
    type: File
    secondaryFiles:
      - .tbi
  - id: indels_recalibration
    type: File
    secondaryFiles:
      - .tbi
  - id: indels_tranches
    type: File
  - id: snps_recalibration
    type: File
    secondaryFiles:
      - .tbi
  - id: snps_tranches
    type: File
  - id: indel_filter_level
    type: float
  - id: snp_filter_level
    type: float
outputs:
  - id: recalibrated_vcf
    type: File
    outputBinding:
      glob: $(inputs.recalibrated_vcf_filename)
    secondaryFiles:
      - .tbi
label: gatk_applyrecalibration
arguments:
  - position: 0
    prefix: '&&'
    valueFrom: >-
      /gatk-launch --javaOptions "-Xmx5g -Xms5g" ApplyVQSR -O
      tmp.indel.recalibrated.vcf -V $(inputs.input_vcf.path) --recalFile
      $(inputs.indels_recalibration.path) -tranchesFile
      $(inputs.indels_tranches.path) -ts_filter_level
      $(inputs.indel_filter_level) --createOutputVariantIndex true -mode INDEL
  - position: 0
    prefix: '&&'
    valueFrom: >-
      /gatk-launch --javaOptions "-Xmx5g -Xms5g" ApplyVQSR -O
      $(inputs.recalibrated_vcf_filename) -V tmp.indel.recalibrated.vcf
      --recalFile $(inputs.snps_recalibration.path) -tranchesFile
      $(inputs.snps_tranches.path) -ts_filter_level $(inputs.snp_filter_level)
      --createOutputVariantIndex true -mode SNP
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc:gatk:4.0.1.0'
'sbg:job':
  inputs:
    recalibrated_vcf_filename: recalibrated_vcf_filename-string-value
    input_vcf:
      basename: input_vcf.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: input_vcf
      path: /path/to/input_vcf.ext
      secondaryFiles: []
      size: 0
    indels_recalibration:
      basename: indels_recalibration.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: indels_recalibration
      path: /path/to/indels_recalibration.ext
      secondaryFiles: []
      size: 0
    indels_tranches:
      basename: indels_tranches.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: indels_tranches
      path: /path/to/indels_tranches.ext
      secondaryFiles: []
      size: 0
    snps_recalibration:
      basename: snps_recalibration.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: snps_recalibration
      path: /path/to/snps_recalibration.ext
      secondaryFiles: []
      size: 0
    snps_tranches:
      basename: snps_tranches.ext
      class: File
      contents: file contents
      nameext: .ext
      nameroot: snps_tranches
      path: /path/to/snps_tranches.ext
      secondaryFiles: []
      size: 0
    indel_filter_level: 0.7600045835438327
    snp_filter_level: 8.2800878832285
  runtime:
    cores: 1
    ram: 1000
