cwlVersion: v1.0
class: CommandLineTool
id: dynamicallycombineintervals
requirements:
- dockerPull: kfdrc/python:2.7.13
  class: DockerRequirement
- class: InlineJavascriptRequirement
baseCommand:
- python
- "-c"
arguments:
- position: 0
  valueFrom: >-
    def parse_interval(interval):
        colon_split = interval.split(":")
        chromosome = colon_split[0]
        dash_split = colon_split[1].split("-")
        start = int(dash_split[0])
        end = int(dash_split[1])
        return chromosome, start, end
    def parse_bed(interval):
        tab_split = interval.split("\t")
        chromosome = tab_split[0]
        start = int(tab_split[1])
        end = int(tab_split[2])
        return chromosome, start, end
    def add_interval(chr, start, end, i):
        fn = "out-{:0>5d}.intervals".format(i)
        lw = chr + ":" + str(start) + "-" + str(end) + "\n"
        with open(fn, "w") as fo:
            fo.writelines(lw)
        return chr, start, end
    def main():
        interval = "$(inputs.interval.path)"
        if interval.endswith(".bed"):
            parse_function = parse_bed
        else:
            parse_function = parse_interval
        num_of_original_intervals = sum(1 for line in open(interval))
        num_gvcfs = $(inputs.input_vcfs.length)
        merge_count = int(num_of_original_intervals/num_gvcfs/2.5) + 1
        count = 0
        i = 1
        chain_count = merge_count
        l_chr, l_start, l_end = "", 0, 0
        if num_of_original_intervals == 1:
            with open(interval) as f:
                for line in f.readlines():
                    w_chr, w_start, w_end = parse_function(line)
                add_interval(w_chr, w_start, w_end, i)
        else:
            with open(interval) as f:
                for line in f.readlines():
                    # initialization
                    if count == 0:
                        w_chr, w_start, w_end = parse_function(line)
                        count = 1
                        continue
                    # reached number to combine, so spit out and start over
                    if count == chain_count:
                        l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)
                        w_chr, w_start, w_end = parse_function(line)
                        count = 1
                        i += 1
                        continue
                    c_chr, c_start, c_end = parse_bed(line)
                    # if adjacent keep the chain going
                    if c_chr == w_chr and c_start == w_end + 1:
                        w_end = c_end
                        count += 1
                        continue
                    # not adjacent, end here and start a new chain
                    else:
                        l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)
                        w_chr, w_start, w_end = parse_function(line)
                        count = 1
                        i += 1
                if l_char != w_chr or l_start != w_start or l_end != w_end:
                    add_interval(w_chr, w_start, w_end, i)
    if __name__ == "__main__":
        main()
inputs:
  interval:
    type: File
  input_vcfs:
    type: File[]
outputs:
  out_intervals:
    type: File[]
    outputBinding:
      glob: out-*.intervals
      outputEval: "${ var i; var name = []; var dict = {}; for (i = 0; i < self.length;
        ++i) { name[i] = self[i].nameroot; dict[self[i].nameroot] = self[i]; }; name
        = name.sort(); for (i = 0; i < name.length; ++i) { self[i] = dict[name[i]];
        }; return self; }"