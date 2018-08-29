{
  "cwlVersion" : "v1.0",
  "inputs" : [ {
    "id" : "bed_file",
    "type" : "File?"
  }, {
    "id" : "variant",
    "type" : "File",
    "secondaryFiles" : [ ".tbi" ]
  } ],
  "outputs" : [ {
    "id" : "select_variants_vcf",
    "type" : "File[]",
    "outputSource" : [ "gatk_4_0_selectvariants/select_variants_vcf" ]
  } ],
  "hints" : [ {
    "class" : "https://sevenbridges.comAWSInstanceType",
    "value" : "m4.10xlarge;ebs-gp2;256"
  } ],
  "requirements" : [ {
    "class" : "ScatterFeatureRequirement"
  } ],
  "successCodes" : [ ],
  "steps" : [ {
    "id" : "gatk_4_0_selectvariants",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "memory_overhead_per_job",
        "type" : "int?",
        "label" : "Memory Overhead Per Job"
      }, {
        "id" : "intervals_file",
        "type" : "File",
        "inputBinding" : {
          "position" : 4,
          "prefix" : "--intervals",
          "shellQuote" : false
        },
        "label" : "Intervals File"
      }, {
        "id" : "reference",
        "type" : "File?",
        "inputBinding" : {
          "position" : 4,
          "prefix" : "--reference",
          "shellQuote" : false
        },
        "secondaryFiles" : [ ".fai", "^.dict" ],
        "label" : "Reference"
      }, {
        "id" : "variant",
        "type" : "File",
        "inputBinding" : {
          "position" : 4,
          "prefix" : "--variant",
          "shellQuote" : false
        },
        "secondaryFiles" : [ ".tbi" ],
        "label" : "Variant"
      }, {
        "id" : "memory_per_job",
        "type" : "int?",
        "label" : "Memory Per Job"
      } ],
      "outputs" : [ {
        "id" : "select_variants_vcf",
        "type" : "File",
        "outputBinding" : {
          "glob" : "*.vcf.gz"
        },
        "secondaryFiles" : [ ".tbi" ],
        "label" : "Select Variants VCF"
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : "${\n    if (inputs.memory_per_job) {\n        if (inputs.memory_overhead_per_job) {\n            return inputs.memory_per_job + inputs.memory_overhead_per_job\n        } else\n            return inputs.memory_per_job\n    } else if (!inputs.memory_per_job && inputs.memory_overhead_per_job) {\n        return 2048 + inputs.memory_overhead_per_job\n    } else\n        return 2048\n}",
        "coresMin" : 1
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "images.sbgenomics.com/teodora_aleksic/gatk:4.0.2.0",
        "dockerImageId" : "3c3b8e0ed4e5"
      }, {
        "class" : "InitialWorkDirRequirement",
        "listing" : [ ]
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/opt/gatk"
      }, {
        "position" : 1,
        "shellQuote" : false,
        "valueFrom" : "--java-options"
      }, {
        "position" : 2,
        "shellQuote" : false,
        "valueFrom" : "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\\\"'\n    }\n    return '\\\"-Xmx2048M\\\"'\n}"
      }, {
        "position" : 3,
        "shellQuote" : false,
        "valueFrom" : "SelectVariants"
      }, {
        "position" : 4,
        "prefix" : "--output",
        "shellQuote" : false,
        "valueFrom" : "${\n    read_namebase = [].concat(inputs.variant)[0].basename\n    bed_name = inputs.intervals_file.nameroot\n    return bed_name + '.' + read_namebase\n}"
      }, {
        "position" : 4,
        "shellQuote" : false,
        "valueFrom" : "${\n    if (inputs.select_expressions) {\n        sexpression = inputs.select_expressions\n        filter = []\n        for (i = 0; i < sexpression.length; i++) {\n            filter.push(\" --selectExpressions '\", sexpression[i], \"'\")\n        }\n        return filter.join(\"\").trim()\n    }\n}"
      } ],
      "id" : "gatk_4_0_selectvariants",
      "class" : "CommandLineTool"
    },
    "scatter" : [ "intervals_file" ],
    "in" : [ {
      "id" : "intervals_file",
      "source" : "sbg_prepare_intervals/intervals"
    }, {
      "id" : "variant",
      "source" : "variant"
    } ],
    "out" : [ {
      "id" : "select_variants_vcf"
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
      "source" : "bed_file"
    }, {
      "id" : "split_mode",
      "valueFrom" : "File per interval"
    } ],
    "out" : [ {
      "id" : "intervals"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  } ],
  "id" : "gvcf_splitter",
  "class" : "Workflow"
}
