cwlVersion: v1.0
class: CommandLineTool
id: sbg_prepare_intervals
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: 1000
  coresMin: 1
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/bogdang/sbg_prepare_intervals:1.0
- class: InitialWorkDirRequirement
  listing:
  - entryname: sbg_prepare_intervals.py
    entry: |-
      """
      Usage:
          sbg_prepare_intervals.py [options] [--fastq FILE --bed FILE --mode INT --format STR --others STR]

      Description:
          Purpose of this tool is to split BED file into files based on the selected mode.
          If bed file is not provided fai(fasta index) file is converted to bed.

      Options:

          -h, --help            Show this message.

          -v, -V, --version     Tool version.

          -b, -B, --bed FILE    Path to input bed file.

          --fai FILE            Path to input fai file.

          --format STR          Output file format.

          --mode INT            Select input mode.

      """

      from docopt import docopt
      import os
      import shutil
      import glob

      default_extension = '.bed'  # for output files


      def create_file(contents, contig_name, extension=default_extension):
          """function for creating a file for all intervals in a contig"""

          new_file = open("Intervals/" + contig_name + extension, "w")
          new_file.write(contents)
          new_file.close()


      def add_to_file(line, name, extension=default_extension):
          """function for adding a line to a file"""

          new_file = open("Intervals/" + name + extension, "a")
          if lformat == formats[1]:
              sep = line.split("\t")
              line = sep[0] + ":" + sep[1] + "-" + sep[2]
          new_file.write(line)
          new_file.close()


      def fai2bed(fai):
          """function to create a bed file from fai file"""

          region_thr = 10000000  # threshold used to determine starting point accounting for telomeres in chromosomes
          basename = fai[0:fai.rfind(".")]
          with open(fai, "r") as ins:
              new_array = []
              for line in ins:
                  len_reg = int(line.split()[1])
                  cutoff = 0 if (
                  len_reg < region_thr) else 0  # sd\\telomeres or start with 1
                  new_line = line.split()[0] + '\t' + str(cutoff) + '\t' + str(
                      len_reg + cutoff)
                  new_array.append(new_line)
          new_file = open(basename + ".bed", "w")
          new_file.write("\n".join(new_array))
          return basename + ".bed"


      def chr_intervals(no_of_chrms=23):
          """returns all possible designations for chromosome intervals"""

          chrms = []
          for i in range(1, no_of_chrms):
              chrms.append("chr" + str(i))
              chrms.append(str(i))
          chrms.extend(["x", "y", "chrx", "chry"])
          return chrms


      def mode_1(orig_file):
          """mode 1: every line is a new file"""

          with open(orig_file, "r") as ins:
              prev = ""
              counter = 0
              names = []
              for line in ins:
                  if line.startswith('@'):
                      continue
                  if line.split()[0] == prev:
                      counter += 1
                  else:
                      counter = 0
                  suffix = "" if (counter == 0) else "_" + str(counter)
                  create_file(line, line.split()[0] + suffix)
                  names.append(line.split()[0] + suffix)
                  prev = line.split()[0]

              create_file(str(names), "names", extension=".txt")


      def mode_2(orig_file, others_name):
          """mode 2: separate file is created for each chromosome, and one file is created for other intervals"""

          chrms = chr_intervals()
          names = []

          with open(orig_file, 'r') as ins:
              for line in ins:
                  if line.startswith('@'):
                      continue
                  name = line.split()[0]
                  if name.lower() in chrms:
                      name = name
                  else:
                      name = others_name
                  try:
                      add_to_file(line, name)
                      if not name in names:
                          names.append(name)
                  except:
                      raise Exception(
                          "Couldn't create or write in the file in mode 2")

              create_file(str(names), "names", extension=".txt")


      def mode_3(orig_file, extension=default_extension):
          """mode 3: input file is staged to output"""

          orig_name = orig_file.split("/")[len(orig_file.split("/")) - 1]
          output_file = r"./Intervals/" + orig_name[
                                          0:orig_name.rfind('.')] + extension

          shutil.copyfile(orig_file, output_file)

          names = [orig_name[0:orig_name.rfind('.')]]
          create_file(str(names), "names", extension=".txt")


      def mode_4(orig_file, others_name):
          """mode 4: every interval in chromosomes is in a separate file. Other intervals are in a single file"""

          chrms = chr_intervals()
          names = []

          with open(orig_file, "r") as ins:
              counter = {}
              for line in ins:
                  if line.startswith('@'):
                      continue
              name = line.split()[0].lower()
              if name in chrms:
                  if name in counter:
                      counter[name] += 1
                  else:
                      counter[name] = 0
                  suffix = "" if (counter[name] == 0) else "_" + str(counter[name])
                  create_file(line, name + suffix)
                  names.append(name + suffix)
                  prev = name
              else:
                  name = others_name
                  if not name in names:
                      names.append(name)
                  try:
                      add_to_file(line, name)
                  except:
                      raise Exception(
                          "Couldn't create or write in the file in mode 4")

          create_file(str(names), "names", extension=".txt")


      def prepare_intervals():
          # reading input files and split mode from command line
          args = docopt(__doc__, version='1.0')

          bed_file = args['--bed']
          fai_file = args['--fai']
          split_mode = int(args['--mode'])

          # define file name for non-chromosomal contigs
          others_name = 'others'

          global formats, lformat
          formats = ["chr start end", "chr:start-end"]
          lformat = args['--format']
          if lformat == None:
              lformat = formats[0]
          if not lformat in formats:
              raise Exception('Unsuported interval format')

          if not os.path.exists(r"./Intervals"):
              os.mkdir(r"./Intervals")
          else:
              files = glob.glob(r"./Intervals/*")
              for f in files:
                  os.remove(f)

          # create variable input_file taking bed_file as priority
          if bed_file:
              input_file = bed_file
          elif fai_file:
              input_file = fai2bed(fai_file)
          else:
              raise Exception('No input files are provided')

          # calling adequate split mode function
          if split_mode == 1:
              mode_1(input_file)
          elif split_mode == 2:
              mode_2(input_file, others_name)
          elif split_mode == 3:
              if bed_file:
                  mode_3(input_file)
              else:
                  raise Exception('Bed file is required for mode 3')
          elif split_mode == 4:
              mode_4(input_file, others_name)
          else:
              raise Exception('Split mode value is not set')


      if __name__ == '__main__':
          prepare_intervals()
  - "$(inputs.bed_file)"
  - "$(inputs.fai_file)"
baseCommand:
- python
- sbg_prepare_intervals.py
arguments:
- position: 0
  shellQuote: false
  valueFrom: |-
    ${
        if (inputs.format)
            return "--format " + "\"" + inputs.format + "\""
    }
inputs:
  fai_file:
    type: File?
    inputBinding:
      position: 2
      prefix: "--fai"
      shellQuote: false
    label: Input FAI file
    doc: FAI file is converted to BED format if BED file is not provided.
  bed_file:
    type: File?
    inputBinding:
      position: 1
      prefix: "--bed"
      shellQuote: false
    label: Input BED file
    doc: Input BED file containing intervals. Required for modes 3 and 4.
  split_mode:
    type:
      type: enum
      symbols:
      - File per interval
      - File per chr with alt contig in a single file
      - Output original BED
      - File per interval with alt contig in a single file
      name: split_mode
    inputBinding:
      position: 3
      prefix: "--mode"
      shellQuote: false
      valueFrom: |-
        ${
            mode = inputs.split_mode
            switch (mode) {
                case "File per interval":
                    return 1
                case "File per chr with alt contig in a single file":
                    return 2
                case "Output original BED":
                    return 3
                case "File per interval with alt contig in a single file":
                    return 4
            }
            return 3
        }
    label: Split mode
    doc: 'Depending on selected Split Mode value, output files are generated in accordance
      with description below:  1. File per interval - The tool creates one interval
      file per line of the input BED(FAI) file. Each interval file contains a single
      line (one of the lines of BED(FAI) input file).  2. File per chr with alt contig
      in a single file - For each contig(chromosome) a single file is created containing
      all the intervals corresponding to it . All the intervals (lines) other than
      (chr1, chr2 ... chrY or 1, 2 ... Y) are saved as ("others.bed").  3. Output
      original BED - BED file is required for execution of this mode. If mode 3 is
      applied input is passed to the output.  4. File per interval with alt contig
      in a single file - For each chromosome a single file is created for each interval.
      All the intervals (lines) other than (chr1, chr2 ... chrY or 1, 2 ... Y) are
      saved as ("others.bed"). NOTE: Do not use option 1 (File per interval) with
      exome BED or a BED with a lot of GL contigs, as it will create a large number
      of files.'
  format:
    type:
    - 'null'
    - type: enum
      symbols:
      - chr start end
      - chr:start-end
      name: format
    label: Interval format
    doc: Format of the intervals in the generated files.
outputs:
  intervals:
    doc: Array of BED files genereted as per selected Split Mode.
    label: Intervals
    type: File[]?
    outputBinding:
      glob: Intervals/*.bed