---
cwlVersion: v1.0
class: CommandLineTool
id: gatk_4_0_selectvariants
requirements:
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
  prefix: ''
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
  interval_exclusion_padding:
    type: int?
    inputBinding:
      position: 4
      prefix: "--interval-exclusion-padding"
      shellQuote: false
    label: Interval Exclusion Padding
  mendelian_violation_qual_threshold:
    type: float?
    inputBinding:
      position: 4
      prefix: "--mendelian-violation-qual-threshold"
      shellQuote: false
    label: Mendelian Violation Qual Threshold
  add_output_sam_program_record:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--add-output-sam-program-record"
      shellQuote: false
    label: Add Output Sam Program Record
  keep_reverse:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--keep-reverse"
      shellQuote: false
    label: Keep Reverse
  disable_tool_default_read_filters:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--disable-tool-default-read-filters"
      shellQuote: false
    label: Disable Tool Default Read Filters
  sample_name:
    type: string?
    inputBinding:
      position: 4
      prefix: "--sample-name"
      shellQuote: false
    label: Sample Name
  input:
    type: File?
    inputBinding:
      position: 4
      prefix: "--input"
      shellQuote: false
    label: Input
    secondaryFiles:
    - ".bai"
  exclude_sample_expressions:
    type: string?
    inputBinding:
      position: 4
      prefix: "--exclude-sample-expressions"
      shellQuote: false
    label: Exclude Sample Expressions
  memory_overhead_per_job:
    type: int?
    label: Memory Overhead Per Job
  mendelian_violation:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--mendelian-violation"
      shellQuote: false
    label: Mendelian Violation
  exclude_filtered:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--exclude-filtered"
      shellQuote: false
    label: Exclude Filtered
  intervals_file:
    type: File?
    inputBinding:
      position: 4
      prefix: "--intervals"
      shellQuote: false
    label: Intervals File
  keep_original_ac:
    type: int?
    inputBinding:
      position: 4
      prefix: "--keep-original-ac"
      shellQuote: false
    label: Keep Original Ac
  disable_read_filter:
    type:
    - 'null'
    - type: enum
      symbols:
      - GoodCigarReadFilter
      - MappedReadFilter
      - MappingQualityAvailableReadFilter
      - MappingQualityReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - NotSecondaryAlignmentReadFilter
      - PassesVendorQualityCheckReadFilter
      - WellformedReadFilter
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--disable-read-filter"
      shellQuote: false
    label: Disable Read Filter
  verbosity:
    type:
    - 'null'
    - type: enum
      symbols:
      - ERROR
      - WARNING
      - INFO
      - DEBUG
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--verbosity"
      shellQuote: false
    label: Verbosity
  min_fraction_filtered_genotypes:
    type: float?
    inputBinding:
      position: 4
      prefix: "--min-fraction-filtered-genotypes"
      shellQuote: false
    label: Min Fraction Filtered Genotypes
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
  create_output_variant_md5:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--create-output-variant-md5"
      shellQuote: false
    label: Create Output Variant Md5
  exclude_sample_file:
    type: File[]?
    inputBinding:
      position: 4
      prefix: "--exclude-sample-file"
      shellQuote: false
    label: Exclude Sample File
  intervals_string:
    type: string?
    inputBinding:
      position: 4
      prefix: "--intervals"
      shellQuote: false
    label: Intervals String
  max_nocal_lnumber:
    type: int?
    inputBinding:
      position: 4
      prefix: "--max-nocal-lnumber"
      shellQuote: false
    label: Max Nocal Lnumber
  pedigree:
    type: File?
    inputBinding:
      position: 4
      prefix: "--pedigree"
      shellQuote: false
    label: Pedigree
  read_validation_stringency:
    type:
    - 'null'
    - type: enum
      symbols:
      - STRICT
      - LENIENT
      - SILENT
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--read-validation-stringency"
      shellQuote: false
    label: Read Validation Stringency
  select_expressions:
    sbg:toolDefaultValue: "[]"
    type: string[]?
    label: Select Expressions
  interval_set_rule:
    type:
    - 'null'
    - type: enum
      symbols:
      - UNION
      - INTERSECTION
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--interval-set-rule"
      shellQuote: false
    label: Interval Set Rule
  restrict_alleles_to:
    type:
    - 'null'
    - type: enum
      symbols:
      - ALL
      - BIALLELIC
      - MULTIALLELIC
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--restrict-alleles-to"
      shellQuote: false
    label: Restrict Alleles To
  keep_original_dp:
    type: int?
    inputBinding:
      position: 4
      prefix: "--keep-original-dp"
      shellQuote: false
    label: Keep Original Dp
  exclude_sample_name:
    type: string?
    inputBinding:
      position: 4
      prefix: "--exclude-sample-name"
      shellQuote: false
    label: Exclude Sample Name
  cloud_prefetch_buffer:
    type: int?
    inputBinding:
      position: 4
      prefix: "--cloud-prefetch-buffer"
      shellQuote: false
    label: Cloud Prefetch Buffer
  set_filtered_gt_to_nocall:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--set-filtered-gt-to-nocall"
      shellQuote: false
    label: Set Filtered Gt To Nocall
  variant:
    type: File
    inputBinding:
      position: 4
      prefix: "--variant"
      shellQuote: false
    label: Variant
    secondaryFiles:
    - ".tbi"
  preserve_alleles:
    type:
    - 'null'
    - type: enum
      symbols:
      - 'true'
      - 'false'
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--preserve-alleles"
      shellQuote: false
    label: Preserve Alleles
  create_output_bam_md5:
    type:
    - 'null'
    - type: enum
      symbols:
      - 'true'
      - 'false'
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--create-output-bam-md5"
      shellQuote: false
    label: Create Output Bam Md5
  disable_bam_index_caching:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--disable-bam-index-caching"
      shellQuote: false
    label: Disable Bam Index Caching
  invert_mendelian_violation:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--invert-mendelian-violation"
      shellQuote: false
    label: Invert Mendelian Violation
  quiet:
    type:
    - 'null'
    - type: enum
      symbols:
      - 'true'
      - 'false'
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--quiet"
      shellQuote: false
    label: Quiet
  read_filter:
    type:
    - 'null'
    - type: enum
      symbols:
      - AlignmentAgreesWithHeaderReadFilter
      - AllowAllReadsReadFilter
      - AmbiguousBaseReadFilter
      - CigarContainsNoNOperator
      - FirstOfPairReadFilter
      - FragmentLengthReadFilter
      - GoodCigarReadFilter
      - HasReadGroupReadFilter
      - LibraryReadFilter
      - MappedReadFilter
      - MappingQualityAvailableReadFilter
      - MappingQualityNotZeroReadFilter
      - MappingQualityReadFilter
      - MatchingBasesAndQualsReadFilter
      - MateDifferentStrandReadFilter
      - MateOnSameContigOrNoMappedMateReadFilter
      - MetricsReadFilter
      - NonZeroFragmentLengthReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - NotOpticalDuplicateReadFilter
      - NotSecondaryAlignmentReadFilter
      - NotSupplementaryAlignmentReadFilter
      - OverclippedReadFilter
      - PairedReadFilter
      - PassesVendorQualityCheckReadFilter
      - PlatformReadFilter
      - PlatformUnitReadFilter
      - PrimaryLineReadFilter
      - ProperlyPairedReadFilter
      - ReadGroupBlackListReadFilter
      - ReadGroupReadFilter
      - ReadLengthEqualsCigarLengthReadFilter
      - ReadLengthReadFilter
      - ReadNameReadFilter
      - ReadStrandFilter
      - SampleReadFilter
      - SecondOfPairReadFilter
      - SeqIsStoredReadFilter
      - ValidAlignmentEndReadFilter
      - ValidAlignmentStartReadFilter
      - WellformedReadFilter
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--read-filter"
      shellQuote: false
    label: Read Filter
  ambig_filter_frac:
    type: float?
    inputBinding:
      position: 4
      prefix: "--ambig-filter-frac"
      shellQuote: false
    label: Ambig Filter Frac
  invert_select:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--invert-select"
      shellQuote: false
    label: Invert Select
  max_indel_size:
    type: int?
    inputBinding:
      position: 4
      prefix: "--max-indel-size"
      shellQuote: false
    label: Max Indel Size
  remove_fraction_genotypes:
    type: float?
    inputBinding:
      position: 4
      prefix: "--remove-fraction-genotypes"
      shellQuote: false
    label: Remove Fraction Genotypes
  select_random_fraction:
    type: float?
    inputBinding:
      position: 4
      prefix: "--select-random-fraction"
      shellQuote: false
    label: Select Random Fraction
  create_output_variant_index:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--create-output-variant-index"
      shellQuote: false
    label: Create Output Variant Index
  select_type_to_exclude:
    type:
    - 'null'
    - type: enum
      symbols:
      - NO_VARIATION
      - SNP
      - MNP
      - INDEL
      - SYMBOLIC
      - MIXED
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--select-type-to-exclude"
      shellQuote: false
    label: Select Type To Exclude
  sample_expressions:
    type: string?
    inputBinding:
      position: 4
      prefix: "--sample-expressions"
      shellQuote: false
    label: Sample Expressions
  exclude_ids:
    type: File?
    inputBinding:
      position: 4
      prefix: "--exclude-ids"
      shellQuote: false
    label: Exclude I Ds
  black_listed_lanes:
    type: string?
    inputBinding:
      position: 4
      prefix: "--black-listed-lanes"
      shellQuote: false
    label: Black Listed Lanes
  ambig_filter_bases:
    type: int?
    inputBinding:
      position: 4
      prefix: "--ambig-filter-bases"
      shellQuote: false
    label: Ambig Filter Bases
  pl_filter_name:
    type: string?
    inputBinding:
      position: 4
      prefix: "--pl-filter-name"
      shellQuote: false
    label: Pl Filter Name
  filter_too_short:
    type: int?
    inputBinding:
      position: 4
      prefix: "--filter-too-short"
      shellQuote: false
    label: Filter Too Short
  library:
    type: string?
    inputBinding:
      position: 4
      prefix: "--library"
      shellQuote: false
    label: Library
  use_jdk_inflater:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--use-jdk-inflater"
      shellQuote: false
    label: Use Jdk Inflater
  min_filtered_genotypes:
    type: int?
    inputBinding:
      position: 4
      prefix: "--min-filtered-genotypes"
      shellQuote: false
    label: Min Filtered Genotypes
  discordance:
    type: File?
    inputBinding:
      position: 4
      prefix: "--discordance"
      shellQuote: false
    label: Discordance
  maximum_mapping_quality:
    type: int?
    inputBinding:
      position: 4
      prefix: "--maximum-mapping-quality"
      shellQuote: false
    label: Maximum Mapping Quality
  read_name:
    type: string?
    inputBinding:
      position: 4
      prefix: "--read-name"
      shellQuote: false
    label: Read Name
  sample_file:
    type: File?
    inputBinding:
      position: 4
      prefix: "--sample-file"
      shellQuote: false
    label: Sample File
  exclude_non_variants:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--exclude-non-variants"
      shellQuote: false
    label: Exclude Non Variants
  max_fragment_length:
    type: int?
    inputBinding:
      position: 4
      prefix: "--max-fragment-length"
      shellQuote: false
    label: Max Fragment Length
  exclude_intervals_file:
    type: File?
    inputBinding:
      position: 4
      prefix: "--exclude-intervals"
      shellQuote: false
    label: Exclude Intervals File
  min_read_length:
    type: int?
    inputBinding:
      position: 4
      prefix: "--min-read-length"
      shellQuote: false
    label: Min Read Length
  sample:
    type: string?
    inputBinding:
      position: 4
      prefix: "--sample"
      shellQuote: false
    label: Sample
  max_nocal_lfraction:
    type: float?
    inputBinding:
      position: 4
      prefix: "--max-nocal-lfraction"
      shellQuote: false
    label: Max Nocal Lfraction
  black_list:
    type: string?
    inputBinding:
      position: 4
      prefix: "--black-list"
      shellQuote: false
    label: Black List
  max_filtered_genotypes:
    type: int?
    inputBinding:
      position: 4
      prefix: "--max-filtered-genotypes"
      shellQuote: false
    label: Max Filtered Genotypes
  remove_unused_alternates:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--remove-unused-alternates"
      shellQuote: false
    label: Remove Unused Alternates
  exclude_intervals_string:
    type: string?
    inputBinding:
      position: 4
      prefix: "--exclude-intervals"
      shellQuote: false
    label: Exclude Intervals String
  use_jdk_deflater:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--use-jdk-deflater"
      shellQuote: false
    label: Use Jdk Deflater
  create_output_bam_index:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--create-output-bam-index"
      shellQuote: false
    label: Create Output Bam Index
  min_indel_size:
    type: int?
    inputBinding:
      position: 4
      prefix: "--min-indel-size"
      shellQuote: false
    label: Min Indel Size
  minimum_mapping_quality:
    type: int?
    inputBinding:
      position: 4
      prefix: "--minimum-mapping-quality"
      shellQuote: false
    label: Minimum Mapping Quality
  max_read_length:
    type: int?
    inputBinding:
      position: 4
      prefix: "--max-read-length"
      shellQuote: false
    label: Max Read Length
  disable_sequence_dictionary_validation:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--disable-sequence-dictionary-validation"
      shellQuote: false
    label: Disable Sequence Dictionary Validation
  cloud_index_prefetch_buffer:
    type: int?
    inputBinding:
      position: 4
      prefix: "--cloud-index-prefetch-buffer"
      shellQuote: false
    label: Cloud Index Prefetch Buffer
  lenient:
    type: int?
    inputBinding:
      position: 4
      prefix: "--lenient"
      shellQuote: false
    label: Lenient
  memory_per_job:
    type: int?
    label: Memory Per Job
  read_index:
    type: string?
    inputBinding:
      position: 4
      prefix: "--read-index"
      shellQuote: false
    label: Read Index
  dont_require_soft_clips_both_ends:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--dont-require-soft-clips-both-ends"
      shellQuote: false
    label: Dont Require Soft Clips Both Ends
  keep_ids:
    type: File?
    inputBinding:
      position: 4
      prefix: "--keep-ids"
      shellQuote: false
    label: Keep I Ds
  max_fraction_filtered_genotypes:
    type: float?
    inputBinding:
      position: 4
      prefix: "--max-fraction-filtered-genotypes"
      shellQuote: false
    label: Max Fraction Filtered Genotypes
  seconds_between_progress_updates:
    type: float?
    inputBinding:
      position: 4
      prefix: "--seconds-between-progress-updates"
      shellQuote: false
    label: Seconds Between Progress Updates
  interval_merging_rule:
    sbg:toolDefaultValue: ALL
    type:
    - 'null'
    - type: enum
      symbols:
      - ALL
      - OVERLAPPING_ONLY
      name: interval_merging_rule
    inputBinding:
      position: 4
      prefix: "--interval-merging-rule"
      shellQuote: false
    label: Interval Merging Rule
  gcs_max_retries:
    sbg:toolDefaultValue: '20'
    type: int?
    inputBinding:
      position: 4
      prefix: "--gcs-max-retries"
      shellQuote: false
    label: Gcs Max Retries
  keep_read_group:
    type: string?
    inputBinding:
      position: 4
      prefix: "--keep-read-group"
      shellQuote: false
    label: Keep Read Group
  concordance:
    type: string?
    inputBinding:
      position: 4
      prefix: "--concordance"
      shellQuote: false
    label: Concordance
  select_type_to_include:
    type:
    - 'null'
    - type: enum
      symbols:
      - NO_VARIATION
      - SNP
      - MNP
      - INDEL
      - SYMBOLIC
      - MIXED
      name: 'null'
    inputBinding:
      position: 4
      prefix: "--select-type-to-include"
      shellQuote: false
    label: Select Type To Include
  interval_padding:
    type: int?
    inputBinding:
      position: 4
      prefix: "--interval-padding"
      shellQuote: false
    label: Interval Padding
outputs:
  select_variants_vcf:
    label: Select Variants VCF
    type: File
    outputBinding:
      glob: "*.vcf.gz"
    secondaryFiles:
    - ".tbi"