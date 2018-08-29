{
  "cwlVersion" : "v1.0",
  "inputs" : [ {
    "id" : "reference_dict",
    "type" : "File"
  }, {
    "id" : "hapmap_resource_vcf",
    "type" : "File"
  }, {
    "id" : "output_vcf_basename",
    "type" : "string"
  }, {
    "id" : "one_thousand_genomes_resource_vcf",
    "type" : "File"
  }, {
    "id" : "sites_only_vcfs",
    "type" : {
      "inputBinding" : {
        "prefix" : "-I"
      },
      "items" : "File",
      "type" : "array"
    },
    "label" : "Sites Only VCFs"
  }, {
    "id" : "wgs_evaluation_interval_list",
    "type" : "File"
  }, {
    "id" : "omni_resource_vcf",
    "type" : "File"
  }, {
    "id" : "mills_resource_vcf",
    "type" : "File"
  }, {
    "id" : "filtered_vcfs",
    "type" : {
      "inputBinding" : {
        "prefix" : "-I"
      },
      "items" : "File",
      "type" : "array"
    },
    "label" : "Variant Filtered VCFs"
  }, {
    "id" : "dbsnp_vcf",
    "type" : "File"
  }, {
    "id" : "axiomPoly_resource_vcf",
    "type" : "File"
  } ],
  "outputs" : [ {
    "id" : "finalgathervcf",
    "type" : "File",
    "outputSource" : [ "gatk_finalgathervcf/output" ]
  }, {
    "id" : "collectvariantcallingmetrics",
    "type" : "File[]",
    "outputSource" : [ "picard_collectvariantcallingmetrics/output" ]
  } ],
  "hints" : [ {
    "class" : "https://sevenbridges.comAWSInstanceType",
    "value" : "r4.8xlarge;ebs-gp2;3500"
  }, {
    "class" : "https://sevenbridges.commaxNumberOfParallelInstances",
    "value" : 4
  } ],
  "requirements" : [ {
    "class" : "ScatterFeatureRequirement"
  } ],
  "successCodes" : [ ],
  "steps" : [ {
    "id" : "gatk_applyrecalibration",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "indels_recalibration",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      }, {
        "id" : "indels_tranches",
        "type" : "File"
      }, {
        "id" : "snps_recalibration",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      }, {
        "id" : "snps_tranches",
        "type" : "File"
      } ],
      "outputs" : [ {
        "id" : "recalibrated_vcf",
        "type" : "File",
        "outputBinding" : {
          "glob" : "scatter.filtered.vcf.gz"
        },
        "secondaryFiles" : [ ".tbi" ]
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.0.1.2"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 2
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk --java-options \"-Xmx5g -Xms5g\" ApplyVQSR -O tmp.indel.recalibrated.vcf -V $(inputs.input_vcf.path) --recal-file $(inputs.indels_recalibration.path) --tranches-file $(inputs.indels_tranches.path) -ts-filter-level 99.7 --create-output-bam-index true -mode INDEL\n/gatk --java-options \"-Xmx5g -Xms5g\" ApplyVQSR -O scatter.filtered.vcf.gz -V tmp.indel.recalibrated.vcf --recal-file $(inputs.snps_recalibration.path) --tranches-file $(inputs.snps_tranches.path) -ts-filter-level 99.7 --create-output-bam-index true -mode SNP"
      } ],
      "id" : "gatk_applyrecalibration",
      "class" : "CommandLineTool"
    },
    "scatter" : [ "input_vcf", "snps_recalibration" ],
    "scatterMethod" : "dotproduct",
    "in" : [ {
      "id" : "input_vcf",
      "source" : "filtered_vcfs"
    }, {
      "id" : "indels_recalibration",
      "source" : "gatk_indelsvariantrecalibrator/recalibration"
    }, {
      "id" : "indels_tranches",
      "source" : "gatk_indelsvariantrecalibrator/tranches"
    }, {
      "id" : "snps_recalibration",
      "source" : "gatk_snpsvariantrecalibratorscattered/recalibration"
    }, {
      "id" : "snps_tranches",
      "source" : "gatk_gathertranches/output"
    } ],
    "out" : [ {
      "id" : "recalibrated_vcf"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_snpsvariantrecalibratorscattered",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "sites_only_variant_filtered_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "model_report",
        "type" : "File"
      }, {
        "id" : "hapmap_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "omni_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "one_thousand_genomes_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "dbsnp_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      } ],
      "outputs" : [ {
        "id" : "recalibration",
        "type" : "File",
        "outputBinding" : {
          "glob" : "scatter.snps.recal"
        },
        "secondaryFiles" : [ ".idx" ]
      }, {
        "id" : "tranches",
        "type" : "File",
        "outputBinding" : {
          "glob" : "scatter.snps.tranches"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.5"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 1
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk-launch --javaOptions \"-Xmx3g -Xms3g\" VariantRecalibrator -V $(inputs.sites_only_variant_filtered_vcf.path) -O scatter.snps.recal -tranchesFile scatter.snps.tranches -allPoly -mode SNP --input_model $(inputs.model_report.path) -scatterTranches --maxGaussians 6 -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path) -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path) -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path) -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path) -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP"
      } ],
      "id" : "gatk_snpsvariantrecalibratorscattered",
      "class" : "CommandLineTool"
    },
    "scatter" : [ "sites_only_variant_filtered_vcf" ],
    "in" : [ {
      "id" : "sites_only_variant_filtered_vcf",
      "source" : "sites_only_vcfs"
    }, {
      "id" : "model_report",
      "source" : "gatk_snpsvariantrecalibratorcreatemodel/model_report"
    }, {
      "id" : "hapmap_resource_vcf",
      "source" : "hapmap_resource_vcf"
    }, {
      "id" : "omni_resource_vcf",
      "source" : "omni_resource_vcf"
    }, {
      "id" : "one_thousand_genomes_resource_vcf",
      "source" : "one_thousand_genomes_resource_vcf"
    }, {
      "id" : "dbsnp_resource_vcf",
      "source" : "dbsnp_vcf"
    } ],
    "out" : [ {
      "id" : "recalibration"
    }, {
      "id" : "tranches"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_gathervcfs",
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
          "glob" : "sites_only.vcf.gz"
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
        "shellQuote" : false,
        "valueFrom" : "/gatk/gatk-launch --javaOptions \"-Xmx6g -Xms6g\" GatherVcfsCloud --ignoreSafetyChecks --gatherType BLOCK --output sites_only.vcf.gz"
      }, {
        "position" : 2,
        "shellQuote" : false,
        "valueFrom" : "&& /tabix/tabix sites_only.vcf.gz"
      } ],
      "id" : "gatk_gathergvcfs",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcfs",
      "source" : "sites_only_vcfs"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_snpsvariantrecalibratorcreatemodel",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "sites_only_variant_filtered_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "hapmap_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "omni_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "one_thousand_genomes_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "dbsnp_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      } ],
      "outputs" : [ {
        "id" : "model_report",
        "type" : "File",
        "outputBinding" : {
          "glob" : "snps.model.report"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.0.3.0"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 1
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk --java-options \"-Xmx100g -Xms50g\" VariantRecalibrator -V $(inputs.sites_only_variant_filtered_vcf.path) -O snps.recal --tranches-file snps.tranches --trust-all-polymorphic --mode SNP --output-model snps.model.report --max-gaussians 6 -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path) -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path) -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path) -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path) -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP"
      } ],
      "id" : "gatk_snpsvariantrecalibratorcreatemodel",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "sites_only_variant_filtered_vcf",
      "source" : "gatk_gathervcfs/output"
    }, {
      "id" : "hapmap_resource_vcf",
      "source" : "hapmap_resource_vcf"
    }, {
      "id" : "omni_resource_vcf",
      "source" : "omni_resource_vcf"
    }, {
      "id" : "one_thousand_genomes_resource_vcf",
      "source" : "one_thousand_genomes_resource_vcf"
    }, {
      "id" : "dbsnp_resource_vcf",
      "source" : "dbsnp_vcf"
    } ],
    "out" : [ {
      "id" : "model_report"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_gathertranches",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "tranches",
        "type" : {
          "inputBinding" : {
            "prefix" : "--input"
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
          "glob" : "snps.gathered.tranches"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.5"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 2
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk-launch --javaOptions \"-Xmx6g -Xms6g\" GatherTranches --output snps.gathered.tranches"
      } ],
      "id" : "gatk_gathertranches",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "tranches",
      "source" : "gatk_snpsvariantrecalibratorscattered/tranches"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_indelsvariantrecalibrator",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "sites_only_variant_filtered_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "mills_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "axiomPoly_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "dbsnp_resource_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      } ],
      "outputs" : [ {
        "id" : "recalibration",
        "type" : "File",
        "outputBinding" : {
          "glob" : "indels.recal"
        },
        "secondaryFiles" : [ ".idx" ]
      }, {
        "id" : "tranches",
        "type" : "File",
        "outputBinding" : {
          "glob" : "indels.tranches"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.5"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 1
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk-launch --javaOptions \"-Xmx24g -Xms24g\" VariantRecalibrator -V $(inputs.sites_only_variant_filtered_vcf.path) -O indels.recal -tranchesFile indels.tranches -allPoly -mode INDEL --maxGaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:$(inputs.mills_resource_vcf.path) -resource axiomPoly,known=false,training=true,truth=false,prior=10:$(inputs.axiomPoly_resource_vcf.path) -resource dbsnp,known=true,training=false,truth=false,prior=2:$(inputs.dbsnp_resource_vcf.path) -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP"
      } ],
      "id" : "gatk_indelsvariantrecalibrator",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "sites_only_variant_filtered_vcf",
      "source" : "gatk_gathervcfs/output"
    }, {
      "id" : "mills_resource_vcf",
      "source" : "mills_resource_vcf"
    }, {
      "id" : "axiomPoly_resource_vcf",
      "source" : "axiomPoly_resource_vcf"
    }, {
      "id" : "dbsnp_resource_vcf",
      "source" : "dbsnp_vcf"
    } ],
    "out" : [ {
      "id" : "recalibration"
    }, {
      "id" : "tranches"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "gatk_finalgathervcf",
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
      }, {
        "id" : "output_vcf_name",
        "type" : "string"
      } ],
      "outputs" : [ {
        "id" : "output",
        "type" : "File",
        "outputBinding" : {
          "glob" : "$(inputs.output_vcf_name)"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/gatk:4.beta.5"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 2
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 0,
        "shellQuote" : false,
        "valueFrom" : "/gatk-launch --javaOptions \"-Xmx6g -Xms6g\" GatherVcfs --ignoreSafetyChecks --gatherType BLOCK --output $(inputs.output_vcf_name)"
      } ],
      "id" : "gatk_gathervcfs",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcfs",
      "source" : "gatk_applyrecalibration/recalibrated_vcf"
    }, {
      "id" : "output_vcf_name",
      "source" : "output_vcf_basename"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  }, {
    "id" : "picard_collectvariantcallingmetrics",
    "run" : {
      "cwlVersion" : "v1.0",
      "inputs" : [ {
        "id" : "input_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".tbi" ]
      }, {
        "id" : "reference_dict",
        "type" : "File"
      }, {
        "id" : "final_gvcf_base_name",
        "type" : "string"
      }, {
        "id" : "dbsnp_vcf",
        "type" : "File",
        "secondaryFiles" : [ ".idx" ]
      }, {
        "id" : "wgs_evaluation_interval_list",
        "type" : "File"
      } ],
      "outputs" : [ {
        "id" : "output",
        "type" : "File[]",
        "outputBinding" : {
          "glob" : "*_metrics"
        }
      } ],
      "hints" : [ ],
      "requirements" : [ {
        "class" : "InlineJavascriptRequirement"
      }, {
        "class" : "ShellCommandRequirement"
      }, {
        "class" : "DockerRequirement",
        "dockerPull" : "kfdrc/picard:2.8.3"
      }, {
        "class" : "ResourceRequirement",
        "ramMin" : 7000,
        "coresMin" : 8
      } ],
      "successCodes" : [ ],
      "baseCommand" : [ ],
      "arguments" : [ {
        "position" : 1,
        "shellQuote" : false,
        "valueFrom" : "java -Xmx6g -Xms6g -jar /picard.jar CollectVariantCallingMetrics INPUT=$(inputs.input_vcf.path) OUTPUT=$(inputs.final_gvcf_base_name) DBSNP=$(inputs.dbsnp_vcf.path) SEQUENCE_DICTIONARY=$(inputs.reference_dict.path) TARGET_INTERVALS=$(inputs.wgs_evaluation_interval_list.path) THREAD_COUNT=8"
      } ],
      "id" : "gatk_collectgvcfcallingmetrics",
      "class" : "CommandLineTool"
    },
    "in" : [ {
      "id" : "input_vcf",
      "source" : "gatk_finalgathervcf/output"
    }, {
      "id" : "reference_dict",
      "source" : "reference_dict"
    }, {
      "id" : "final_gvcf_base_name",
      "source" : "output_vcf_basename"
    }, {
      "id" : "dbsnp_vcf",
      "source" : "dbsnp_vcf"
    }, {
      "id" : "wgs_evaluation_interval_list",
      "source" : "wgs_evaluation_interval_list"
    } ],
    "out" : [ {
      "id" : "output"
    } ],
    "hints" : [ ],
    "requirements" : [ ]
  } ],
  "id" : "kfdrc-jointgenotyping-intervals",
  "class" : "Workflow"
}
