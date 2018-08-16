cwlVersion: v1.0
class: CommandLineTool
id: bedtools_intersect
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: 1000
  coresMin: 1
- class: DockerRequirement
  dockerImageId: ad2043b902a2
  dockerPull: images.sbgenomics.com/thedzo/bedtools:2.25.0
- class: InitialWorkDirRequirement
  listing: []
- class: InlineJavascriptRequirement
baseCommand:
- bedtools
- intersect
inputs:
  input_buf_size:
    type: int?
    inputBinding:
      position: 0
      prefix: "-iobuf"
      shellQuote: false
    label: Input buffer size
  write_overlap_additional:
    type: boolean?
    inputBinding:
      position: 0
      prefix: "-wao"
      separate: false
      shellQuote: false
    label: Write A, B, overlap and additional
  input_file_a:
    type: File
    inputBinding:
      position: 99
      prefix: "-a"
      shellQuote: false
    label: Input file A
outputs:
  output_file:
    label: Output result file
    type: File
    outputBinding:
      glob: |-
        ${
            filepath = [].concat(inputs.input_file_a)[0].path
            filename = filepath.split("/").pop()
            basename = filename.substr(0, filename.lastIndexOf("."))

            file_dot_sep = filename.split(".")
            file_ext = file_dot_sep[file_dot_sep.length - 1]

            sufix_ext = file_ext

            if (inputs.output_bed && (file_ext == 'bam')) sufix_ext = "bed"

            input_b_list = [].concat(inputs.input_files_b)
            basename1 = basename
            filepath = input_b_list[0].path
            filename = filepath.split("/").pop()
            basename2 = filename.substr(0, filename.lastIndexOf("."))

            if (input_b_list.length > 1) {
                new_filename = basename1 + ".multi_intersect." + sufix_ext
            } else {
                new_filename = basename1 + ".intersect." + basename2 + "." + sufix_ext
            }

            MAX_LEN = 100
            if (new_filename.length < MAX_LEN)
                return new_filename
            else
                return new_filename.slice(new_filename.length - MAX_LEN)
        }
      outputEval: |-
        ${
            return inheritMetadata(self, inputs.input_file_a)

        }
stdout: |-
  ${
      //sufix = "test";
      filepath = [].concat(inputs.input_file_a)[0].path
      filename = filepath.split("/").pop()
      basename = filename.substr(0, filename.lastIndexOf("."))

      file_dot_sep = filename.split(".")
      file_ext = file_dot_sep[file_dot_sep.length - 1]

      sufix_ext = file_ext

      if (inputs.output_bed && (file_ext == 'bam')) sufix_ext = "bed"

      input_b_list = [].concat(inputs.input_files_b)
      basename1 = basename
      filepath = input_b_list[0].path
      filename = filepath.split("/").pop()
      basename2 = filename.substr(0, filename.lastIndexOf("."))

      if (input_b_list.length > 1) {
          new_filename = basename1 + ".multi_intersect." + sufix_ext
      } else {
          new_filename = basename1 + ".intersect." + basename2 + "." + sufix_ext
      }

      MAX_LEN = 100
      if (new_filename.length < MAX_LEN)
          return new_filename
      else
          return new_filename.slice(new_filename.length - MAX_LEN)
  }