{
  "cwlVersion" : "v1.0",
  "inputs" : [ {
    "id" : "scatter_intervals",
    "type" : "File"
  }, {
    "id" : "gvcf_divide_intervals",
    "type" : "File?"
  }, {
    "id" : "ref_fasta",
    "type" : "File"
  }, {
    "id" : "input_vcfs",
    "type" : {
      "inputBinding" : {
        "prefix" : "-V"
      },
      "items" : "File",
      "type" : "array"
    }
  }, {
    "id" : "dbsnp_vcf",
    "type" : "File"
  } ],
  "outputs" : [ {
    "id" : "sites_only_vcf",
    "type" : "File",
    "outputSource" : [ "gather_gvcfs_1/output" ]
  }, {
    "id" : "placeholder",
    "type" : "File?",
    "outputSource" : [ "vcf_keeper/output" ]
  }, {
    "id" : "variant_filtered_vcf",
    "type" : "File",
    "outputSource" : [ "gather_gvcfs/output" ]
  } ],
  "hints" : [ {
    "class" : "sbg:maxNumberOfParallelInstances",
    "value" : "1"
  }, {
    "class" : "sbg:AWSInstanceType",
    "value" : "r4.4xlarge;ebs-gp2;2048"
  } ],
  "requirements" : [ {
    "class" : "ScatterFeatureRequirement"
  }, {
    "class" : "MultipleInputFeatureRequirement"
  } ],
  "successCodes" : [ ],
  "steps" : [ {
    "id" : "select_bed_v2",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "bed_files",
        "type" : "File[]?"
      }, {
        "id" : "gvcf",
        "type" : "File[]?"
      } ],
      "outputs" : [ {
        "id" : "output_bed_file",
        "type" : "File?",
        "outputBinding" : {
          "glob" : "${\n    gvcf_interval = inputs.gvcf[0].path.split('/').pop().split('.')[0]\n    \n    for (var i=0; i < inputs.bed_files.length;i++) {\n        var bed_path = inputs.bed_files[i].path\n        var bed_name = bed_path.split('/').pop().split('.')[0]\n        if (bed_name == gvcf_interval){\n            specific_bed = bed_path.split('/').pop()\n            return specific_bed\n        }\n    }\n}",
          "outputEval" : "$(inheritMetadata(self, inputs.gvcf))"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "ubuntu:16.04"
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "${\n    gvcf_interval = inputs.gvcf[0].path.split('/').pop().split('.')[0]\n    \n    for (var i=0; i < inputs.bed_files.length;i++) {\n        var bed_path = inputs.bed_files[i].path\n        var bed_name = bed_path.split('/').pop().split('.')[0]\n        if (bed_name == gvcf_interval){\n            specific_bed = bed_path\n            return \"cp \" + specific_bed + \" .\" \n        }\n    }\n}"
      } ],
      "id" : "select-bed-v2",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "gvcf",
      "source" : "input_vcfs"
    }, {
      "id" : "bed_files",
      "source" : "sbg_prepare_intervals/intervals"
    } ],
    "out" : [ {
      "id" : "output_bed_file"
    } ],
    "hints" : [ {
      "class" : "sbg:useSbgFS",
      "value" : "true"
    } ],
    "requirements" : [ ]
  }, {
    "id" : "vcf_keeper",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input",
        "type" : "File[]?"
      } ],
      "outputs" : [ {
        "id" : "output",
        "type" : "File?",
        "outputBinding" : {
          "glob" : "output"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "ubuntu:16.04"
      } ],
      "successCodes" : [ ],
      "stdout" : "output",
      "baseCommand" : [ "echo all done" ],
      "arguments" : [ ],
      "id" : "vcf_keeper",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input",
      "linkMerge" : "merge_flattened",
      "source" : [ "input_vcfs", "gather_gvcfs/output" ]
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "create_vcf_list",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcfs",
        "type" : "File[]"
      } ],
      "outputs" : [ {
        "id" : "vcf_list",
        "type" : "File",
        "outputBinding" : {
          "glob" : "*.txt"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "ubuntu:16.04"
      }, {
        "class" : "InitialWorkDirRequirement",
        "listing" : [ {
          "entry" : "${\n    content = \"\"\n    for(i=0;i<inputs.input_vcfs.length;i++){\n        content += \" -V \" + inputs.input_vcfs[i].path\n    }\n    return content\n}",
          "entryname" : "$(inputs.input_vcfs[0].nameroot).txt"
        } ]
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ "echo creating list" ],
      "arguments" : [ ],
      "id" : "create_vcf_list",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcfs",
      "source" : "input_vcfs"
    } ],
    "out" : [ {
      "id" : "vcf_list"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_import_genotype_filtergvcf_merge",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcfs_list",
        "type" : "File"
      }, {
        "id" : "interval",
        "type" : "File"
      }, {
        "id" : "ref_fasta",
        "type" : "File",
        "secondaryFiles" : [ "^.dict", ".fai" ]
      }, {
        "id" : "dbsnp_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      } ],
      "outputs" : [ {
        "id" : "variant_filtered_vcf",
        "type" : "File",
        "outputBinding" : {
          "glob" : "$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz"
        },
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "sites_only_vcf",
        "type" : "File",
        "outputBinding" : {
          "glob" : "$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).sites_only.variant_filtered.vcf.gz"
        },
        "secondaryFiles" : [ ".tbi" ]
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 16000,
        "coresMin" : 1
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "images.sbgenomics.com/bogdang/gatk-picard:4.0.3"
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk --java-options \"-Xms4g\" GenomicsDBImport --genomicsdb-workspace-path genomicsdb --batch-size 50 -L $(inputs.interval.path) --reader-threads 16 -ip 5"
      }, {
        "position" : 2,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "&& tar -cf genomicsdb.tar genomicsdb\n/gatk --java-options \"-Xmx16g -Xms5g\" GenotypeGVCFs -R $(inputs.ref_fasta.path) -O output.vcf.gz -D $(inputs.dbsnp_vcf.path) -G StandardAnnotation --only-output-calls-starting-in-intervals -new-qual -V gendb://genomicsdb -L $(inputs.interval.path)\n/gatk --java-options \"-Xmx3g -Xms3g\"  VariantFiltration  --filter-expression \"ExcessHet > 54.69\" --filter-name ExcessHet -O $(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz -V output.vcf.gz\njava -Xmx3g -Xms3g -jar /picard.jar MakeSitesOnlyVcf INPUT=$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).variant_filtered.vcf.gz OUTPUT=$(inputs.input_vcfs_list.path.split('/').pop().split('.')[0]).sites_only.variant_filtered.vcf.gz"
      }, {
        "position" : 1,
        "prefix" : "",
        "separate" : false,
        "shellQuote" : false,
        "valueFrom" : "${\n    return \"$(cat \" + inputs.input_vcfs_list.path + \")\"\n}"
      } ],
      "id" : "gatk_import_genotype_filtergvcf_merge",
      "class" : "CommandLineTool"
    },
    "scatter" : [ "interval" ],
    "in" : [ {
      "id" : "interval",
      "source" : "dynamicallycombineintervals_1/out_intervals"
    }, {
      "id" : "ref_fasta",
      "source" : "ref_fasta"
    }, {
      "id" : "dbsnp_vcf",
      "source" : "dbsnp_vcf"
    }, {
      "id" : "input_vcfs_list",
      "source" : "create_vcf_list/vcf_list"
    } ],
    "out" : [ {
      "id" : "variant_filtered_vcf"
    }, {
      "id" : "sites_only_vcf"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "dynamicallycombineintervals_1",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "interval",
        "type" : "File"
      }, {
        "id" : "input_vcfs",
        "type" : "File[]"
      } ],
      "outputs" : [ {
        "id" : "out_intervals",
        "type" : "File[]",
        "outputBinding" : {
          "glob" : "out-*.intervals",
          "outputEval" : "${ var i; var name = []; var dict = {}; for (i = 0; i < self.length; ++i) { name[i] = self[i].nameroot; dict[self[i].nameroot] = self[i]; }; name = name.sort(); for (i = 0; i < name.length; ++i) { self[i] = dict[name[i]]; }; return self; }"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/python:2.7.13"
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ "python", "-c" ],
      "arguments" : [ {
        "position" : 0,
        "valueFrom" : "def parse_interval(interval):\n    colon_split = interval.split(\":\")\n    chromosome = colon_split[0]\n    dash_split = colon_split[1].split(\"-\")\n    start = int(dash_split[0])\n    end = int(dash_split[1])\n    return chromosome, start, end\ndef parse_bed(interval):\n    tab_split = interval.split(\"\\t\")\n    chromosome = tab_split[0]\n    start = int(tab_split[1])\n    end = int(tab_split[2])\n    return chromosome, start, end\ndef add_interval(chr, start, end, i):\n    fn = \"out-{:0>5d}.intervals\".format(i)\n    lw = chr + \":\" + str(start) + \"-\" + str(end) + \"\\n\"\n    with open(fn, \"w\") as fo:\n        fo.writelines(lw)\n    return chr, start, end\ndef main():\n    interval = \"$(inputs.interval.path)\"\n    if interval.endswith(\".bed\"):\n        parse_function = parse_bed\n    else:\n        parse_function = parse_interval\n    num_of_original_intervals = sum(1 for line in open(interval))\n    num_gvcfs = $(inputs.input_vcfs.length)\n    merge_count = int(num_of_original_intervals/num_gvcfs/2.5) + 1\n    count = 0\n    i = 1\n    chain_count = merge_count\n    l_chr, l_start, l_end = \"\", 0, 0\n    if num_of_original_intervals == 1:\n        with open(interval) as f:\n            for line in f.readlines():\n                w_chr, w_start, w_end = parse_function(line)\n            add_interval(w_chr, w_start, w_end, i)\n    else:\n        with open(interval) as f:\n            for line in f.readlines():\n                # initialization\n                if count == 0:\n                    w_chr, w_start, w_end = parse_function(line)\n                    count = 1\n                    continue\n                # reached number to combine, so spit out and start over\n                if count == chain_count:\n                    l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)\n                    w_chr, w_start, w_end = parse_function(line)\n                    count = 1\n                    i += 1\n                    continue\n                c_chr, c_start, c_end = parse_bed(line)\n                # if adjacent keep the chain going\n                if c_chr == w_chr and c_start == w_end + 1:\n                    w_end = c_end\n                    count += 1\n                    continue\n                # not adjacent, end here and start a new chain\n                else:\n                    l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)\n                    w_chr, w_start, w_end = parse_function(line)\n                    count = 1\n                    i += 1\n            if l_char != w_chr or l_start != w_start or l_end != w_end:\n                add_interval(w_chr, w_start, w_end, i)\nif __name__ == \"__main__\":\n    main()"
      } ],
      "id" : "dynamicallycombineintervals",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "interval",
      "source" : "bedtools_intersect/output_file"
    }, {
      "id" : "input_vcfs",
      "source" : "input_vcfs"
    } ],
    "out" : [ {
      "id" : "out_intervals"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gather_gvcfs",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcfs",
        "type" : {
          "inputBinding" : {
            "prefix" : "-I"
          },
          "items" : "File",
          "type" : "array"
        },
        "inputBinding" : {
          "position" : 1
        }
      } ],
      "outputs" : [ {
        "id" : "output",
        "type" : "File",
        "outputBinding" : {
          "glob" : "$(inputs.input_vcfs[0].basename)"
        },
        "secondaryFiles" : [ ".tbi" ]
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 10000,
        "coresMin" : 5
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.6-tabix-m"
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "/gatk/gatk-launch --javaOptions \"-Xmx6g -Xms6g\" GatherVcfsCloud --ignoreSafetyChecks --gatherType BLOCK --output $(inputs.input_vcfs[0].basename)"
      }, {
        "position" : 2,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "&& /tabix/tabix $(inputs.input_vcfs[0].basename)"
      } ],
      "id" : "gather_gvcfs",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcfs",
      "source" : "gatk_import_genotype_filtergvcf_merge/variant_filtered_vcf"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "sbg_prepare_intervals",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "fai_file",
        "type" : "File?",
        "inputBinding" : {
          "position" : 2,
          "prefix" : "--fai",
          "shellQuote" : false
        },
        "doc" : "FAI file is converted to BED format if BED file is not provided.",
        "label" : "Input FAI file"
      }, {
        "id" : "bed_file",
        "type" : "File?",
        "inputBinding" : {
          "position" : 1,
          "prefix" : "--bed",
          "shellQuote" : false
        },
        "doc" : "Input BED file containing intervals. Required for modes 3 and 4.",
        "label" : "Input BED file"
      }, {
        "id" : "split_mode",
        "type" : {
          "name" : "split_mode",
          "symbols" : [ "File per interval", "File per chr with alt contig in a single file", "Output original BED", "File per interval with alt contig in a single file" ],
          "type" : "enum"
        },
        "inputBinding" : {
          "position" : 3,
          "prefix" : "--mode",
          "shellQuote" : false,
          "valueFrom" : "${\n    mode = inputs.split_mode\n    switch (mode) {\n        case \"File per interval\":\n            return 1\n        case \"File per chr with alt contig in a single file\":\n            return 2\n        case \"Output original BED\":\n            return 3\n        case \"File per interval with alt contig in a single file\":\n            return 4\n    }\n    return 3\n}"
        },
        "doc" : "Depending on selected Split Mode value, output files are generated in accordance with description below:  1. File per interval - The tool creates one interval file per line of the input BED(FAI) file. Each interval file contains a single line (one of the lines of BED(FAI) input file).  2. File per chr with alt contig in a single file - For each contig(chromosome) a single file is created containing all the intervals corresponding to it . All the intervals (lines) other than (chr1, chr2 ... chrY or 1, 2 ... Y) are saved as (\"others.bed\").  3. Output original BED - BED file is required for execution of this mode. If mode 3 is applied input is passed to the output.  4. File per interval with alt contig in a single file - For each chromosome a single file is created for each interval. All the intervals (lines) other than (chr1, chr2 ... chrY or 1, 2 ... Y) are saved as (\"others.bed\"). NOTE: Do not use option 1 (File per interval) with exome BED or a BED with a lot of GL contigs, as it will create a large number of files.",
        "label" : "Split mode"
      }, {
        "id" : "format",
        "type" : [ "null", {
          "name" : "format",
          "symbols" : [ "chr start end", "chr:start-end" ],
          "type" : "enum"
        } ],
        "doc" : "Format of the intervals in the generated files.",
        "label" : "Interval format"
      } ],
      "outputs" : [ {
        "id" : "intervals",
        "type" : "File[]",
        "outputBinding" : {
          "glob" : "Intervals/*.bed"
        },
        "doc" : "Array of BED files genereted as per selected Split Mode.",
        "label" : "Intervals"
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 1000,
        "coresMin" : 1
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "images.sbgenomics.com/bogdang/sbg_prepare_intervals:1.0"
      }, {
        "class" : "InitialWorkDirRequirement",
        "listing" : [ {
          "entry" : "\"\"\"\nUsage:\n    sbg_prepare_intervals.py [options] [--fastq FILE --bed FILE --mode INT --format STR --others STR]\n\nDescription:\n    Purpose of this tool is to split BED file into files based on the selected mode.\n    If bed file is not provided fai(fasta index) file is converted to bed.\n\nOptions:\n\n    -h, --help            Show this message.\n\n    -v, -V, --version     Tool version.\n\n    -b, -B, --bed FILE    Path to input bed file.\n\n    --fai FILE            Path to input fai file.\n\n    --format STR          Output file format.\n\n    --mode INT            Select input mode.\n\n\"\"\"\n\nfrom docopt import docopt\nimport os\nimport shutil\nimport glob\n\ndefault_extension = '.bed'  # for output files\n\n\ndef create_file(contents, contig_name, extension=default_extension):\n    \"\"\"function for creating a file for all intervals in a contig\"\"\"\n\n    new_file = open(\"Intervals/\" + contig_name + extension, \"w\")\n    new_file.write(contents)\n    new_file.close()\n\n\ndef add_to_file(line, name, extension=default_extension):\n    \"\"\"function for adding a line to a file\"\"\"\n\n    new_file = open(\"Intervals/\" + name + extension, \"a\")\n    if lformat == formats[1]:\n        sep = line.split(\"\\t\")\n        line = sep[0] + \":\" + sep[1] + \"-\" + sep[2]\n    new_file.write(line)\n    new_file.close()\n\n\ndef fai2bed(fai):\n    \"\"\"function to create a bed file from fai file\"\"\"\n\n    region_thr = 10000000  # threshold used to determine starting point accounting for telomeres in chromosomes\n    basename = fai[0:fai.rfind(\".\")]\n    with open(fai, \"r\") as ins:\n        new_array = []\n        for line in ins:\n            len_reg = int(line.split()[1])\n            cutoff = 0 if (\n            len_reg < region_thr) else 0  # sd\\\\telomeres or start with 1\n            new_line = line.split()[0] + '\\t' + str(cutoff) + '\\t' + str(\n                len_reg + cutoff)\n            new_array.append(new_line)\n    new_file = open(basename + \".bed\", \"w\")\n    new_file.write(\"\\n\".join(new_array))\n    return basename + \".bed\"\n\n\ndef chr_intervals(no_of_chrms=23):\n    \"\"\"returns all possible designations for chromosome intervals\"\"\"\n\n    chrms = []\n    for i in range(1, no_of_chrms):\n        chrms.append(\"chr\" + str(i))\n        chrms.append(str(i))\n    chrms.extend([\"x\", \"y\", \"chrx\", \"chry\"])\n    return chrms\n\n\ndef mode_1(orig_file):\n    \"\"\"mode 1: every line is a new file\"\"\"\n\n    with open(orig_file, \"r\") as ins:\n        prev = \"\"\n        counter = 0\n        names = []\n        for line in ins:\n            if line.startswith('@'):\n                continue\n            if line.split()[0] == prev:\n                counter += 1\n            else:\n                counter = 0\n            suffix = \"\" if (counter == 0) else \"_\" + str(counter)\n            create_file(line, line.split()[0] + suffix)\n            names.append(line.split()[0] + suffix)\n            prev = line.split()[0]\n\n        create_file(str(names), \"names\", extension=\".txt\")\n\n\ndef mode_2(orig_file, others_name):\n    \"\"\"mode 2: separate file is created for each chromosome, and one file is created for other intervals\"\"\"\n\n    chrms = chr_intervals()\n    names = []\n\n    with open(orig_file, 'r') as ins:\n        for line in ins:\n            if line.startswith('@'):\n                continue\n            name = line.split()[0]\n            if name.lower() in chrms:\n                name = name\n            else:\n                name = others_name\n            try:\n                add_to_file(line, name)\n                if not name in names:\n                    names.append(name)\n            except:\n                raise Exception(\n                    \"Couldn't create or write in the file in mode 2\")\n\n        create_file(str(names), \"names\", extension=\".txt\")\n\n\ndef mode_3(orig_file, extension=default_extension):\n    \"\"\"mode 3: input file is staged to output\"\"\"\n\n    orig_name = orig_file.split(\"/\")[len(orig_file.split(\"/\")) - 1]\n    output_file = r\"./Intervals/\" + orig_name[\n                                    0:orig_name.rfind('.')] + extension\n\n    shutil.copyfile(orig_file, output_file)\n\n    names = [orig_name[0:orig_name.rfind('.')]]\n    create_file(str(names), \"names\", extension=\".txt\")\n\n\ndef mode_4(orig_file, others_name):\n    \"\"\"mode 4: every interval in chromosomes is in a separate file. Other intervals are in a single file\"\"\"\n\n    chrms = chr_intervals()\n    names = []\n\n    with open(orig_file, \"r\") as ins:\n        counter = {}\n        for line in ins:\n            if line.startswith('@'):\n                continue\n        name = line.split()[0].lower()\n        if name in chrms:\n            if name in counter:\n                counter[name] += 1\n            else:\n                counter[name] = 0\n            suffix = \"\" if (counter[name] == 0) else \"_\" + str(counter[name])\n            create_file(line, name + suffix)\n            names.append(name + suffix)\n            prev = name\n        else:\n            name = others_name\n            if not name in names:\n                names.append(name)\n            try:\n                add_to_file(line, name)\n            except:\n                raise Exception(\n                    \"Couldn't create or write in the file in mode 4\")\n\n    create_file(str(names), \"names\", extension=\".txt\")\n\n\ndef prepare_intervals():\n    # reading input files and split mode from command line\n    args = docopt(__doc__, version='1.0')\n\n    bed_file = args['--bed']\n    fai_file = args['--fai']\n    split_mode = int(args['--mode'])\n\n    # define file name for non-chromosomal contigs\n    others_name = 'others'\n\n    global formats, lformat\n    formats = [\"chr start end\", \"chr:start-end\"]\n    lformat = args['--format']\n    if lformat == None:\n        lformat = formats[0]\n    if not lformat in formats:\n        raise Exception('Unsuported interval format')\n\n    if not os.path.exists(r\"./Intervals\"):\n        os.mkdir(r\"./Intervals\")\n    else:\n        files = glob.glob(r\"./Intervals/*\")\n        for f in files:\n            os.remove(f)\n\n    # create variable input_file taking bed_file as priority\n    if bed_file:\n        input_file = bed_file\n    elif fai_file:\n        input_file = fai2bed(fai_file)\n    else:\n        raise Exception('No input files are provided')\n\n    # calling adequate split mode function\n    if split_mode == 1:\n        mode_1(input_file)\n    elif split_mode == 2:\n        mode_2(input_file, others_name)\n    elif split_mode == 3:\n        if bed_file:\n            mode_3(input_file)\n        else:\n            raise Exception('Bed file is required for mode 3')\n    elif split_mode == 4:\n        mode_4(input_file, others_name)\n    else:\n        raise Exception('Split mode value is not set')\n\n\nif __name__ == '__main__':\n    prepare_intervals()",
          "entryname" : "sbg_prepare_intervals.py"
        }, "$(inputs.bed_file)", "$(inputs.fai_file)" ]
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ "python", "sbg_prepare_intervals.py" ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "${\n    if (inputs.format)\n        return \"--format \" + \"\\\"\" + inputs.format + \"\\\"\"\n}"
      } ],
      "id" : "sbg_prepare_intervals",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "bed_file",
      "source" : "gvcf_divide_intervals"
    }, {
      "id" : "split_mode",
      "default" : "File per interval"
    } ],
    "out" : [ {
      "id" : "intervals"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "bedtools_intersect",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_buf_size",
        "type" : "int?",
        "inputBinding" : {
          "position" : 0,
          "prefix" : "-iobuf",
          "shellQuote" : false
        },
        "label" : "Input buffer size"
      }, {
        "id" : "write_overlap_additional",
        "type" : "boolean?",
        "inputBinding" : {
          "position" : 0,
          "prefix" : "-wao",
          "separate" : false,
          "shellQuote" : false
        },
        "label" : "Write A, B, overlap and additional"
      }, {
        "id" : "input_file_a",
        "type" : "File",
        "inputBinding" : {
          "position" : 99,
          "prefix" : "-a",
          "shellQuote" : false
        },
        "label" : "Input file A"
      } ],
      "outputs" : [ {
        "id" : "output_file",
        "type" : "File",
        "outputBinding" : {
          "glob" : "${\n    filepath = [].concat(inputs.input_file_a)[0].path\n    filename = filepath.split(\"/\").pop()\n    basename = filename.substr(0, filename.lastIndexOf(\".\"))\n\n    file_dot_sep = filename.split(\".\")\n    file_ext = file_dot_sep[file_dot_sep.length - 1]\n\n    sufix_ext = file_ext\n\n    if (inputs.output_bed && (file_ext == 'bam')) sufix_ext = \"bed\"\n\n    input_b_list = [].concat(inputs.input_files_b)\n    basename1 = basename\n    filepath = input_b_list[0].path\n    filename = filepath.split(\"/\").pop()\n    basename2 = filename.substr(0, filename.lastIndexOf(\".\"))\n\n    if (input_b_list.length > 1) {\n        new_filename = basename1 + \".multi_intersect.\" + sufix_ext\n    } else {\n        new_filename = basename1 + \".intersect.\" + basename2 + \".\" + sufix_ext\n    }\n\n    MAX_LEN = 100\n    if (new_filename.length < MAX_LEN)\n        return new_filename\n    else\n        return new_filename.slice(new_filename.length - MAX_LEN)\n}",
          "outputEval" : "${\n    return inheritMetadata(self, inputs.input_file_a)\n\n}"
        },
        "label" : "Output result file"
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 1000,
        "coresMin" : 1
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "images.sbgenomics.com/thedzo/bedtools:2.25.0"
      }, {
        "class" : "InitialWorkDirRequirement",
        "listing" : [ ]
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "stdout" : "${\n    //sufix = \"test\";\n    filepath = [].concat(inputs.input_file_a)[0].path\n    filename = filepath.split(\"/\").pop()\n    basename = filename.substr(0, filename.lastIndexOf(\".\"))\n\n    file_dot_sep = filename.split(\".\")\n    file_ext = file_dot_sep[file_dot_sep.length - 1]\n\n    sufix_ext = file_ext\n\n    if (inputs.output_bed && (file_ext == 'bam')) sufix_ext = \"bed\"\n\n    input_b_list = [].concat(inputs.input_files_b)\n    basename1 = basename\n    filepath = input_b_list[0].path\n    filename = filepath.split(\"/\").pop()\n    basename2 = filename.substr(0, filename.lastIndexOf(\".\"))\n\n    if (input_b_list.length > 1) {\n        new_filename = basename1 + \".multi_intersect.\" + sufix_ext\n    } else {\n        new_filename = basename1 + \".intersect.\" + basename2 + \".\" + sufix_ext\n    }\n\n    MAX_LEN = 100\n    if (new_filename.length < MAX_LEN)\n        return new_filename\n    else\n        return new_filename.slice(new_filename.length - MAX_LEN)\n}",
      "baseCommand" : [ "bedtools", "intersect" ],
      "arguments" : [ ],
      "id" : "bedtools_intersect",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_files_b",
      "source" : "select_bed_v2/output_bed_file"
    }, {
      "id" : "input_file_a",
      "source" : "scatter_intervals"
    } ],
    "out" : [ {
      "id" : "output_file"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gather_gvcfs_1",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcfs",
        "type" : {
          "inputBinding" : {
            "prefix" : "-I"
          },
          "items" : "File",
          "type" : "array"
        },
        "inputBinding" : {
          "position" : 1
        }
      } ],
      "outputs" : [ {
        "id" : "output",
        "type" : "File",
        "outputBinding" : {
          "glob" : "$(inputs.input_vcfs[0].basename)"
        },
        "secondaryFiles" : [ ".tbi" ]
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 10000,
        "coresMin" : 5
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.6-tabix-m"
      }, {
        "class" : "InlineJavascriptRequirement"
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "/gatk/gatk-launch --javaOptions \"-Xmx6g -Xms6g\" GatherVcfsCloud --ignoreSafetyChecks --gatherType BLOCK --output $(inputs.input_vcfs[0].basename)"
      }, {
        "position" : 2,
        "prefix" : "",
        "shellQuote" : false,
        "valueFrom" : "&& /tabix/tabix $(inputs.input_vcfs[0].basename)"
      } ],
      "id" : "gather_gvcfs",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcfs",
      "source" : "gatk_import_genotype_filtergvcf_merge/sites_only_vcf"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  } ],
  "id" : "gatk4-genotypegvcfs-wf",
  "class" : "Workflow"
}
