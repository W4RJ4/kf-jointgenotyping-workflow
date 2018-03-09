class: CommandLineTool
cwlVersion: v1.0
id: picard_gathermetrics
baseCommand: []
inputs:
  - id: input_details
    type:
      type: array
      items: File
      inputBinding:
        valueFrom: $(self.dirname + '/' + self.nameroot)
        prefix: 'I='
        separate: false
    inputBinding:
      position: 0
  - id: output_prefix
    type: string
  - id: input_summaries
    type: 'File[]'
outputs:
  - id: detail_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_detail_metrics
  - id: summary_metrics_file
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_summary_metrics
label: picard_gathermetrics
arguments:
  - position: 0
    prefix: ''
    shellQuote: false
    valueFrom: >-
      java -Xmx2g -Xms2g -jar /picard.jar AccumulateVariantCallingMetrics
      O=$(inputs.output_prefix)
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: kfdrc/picard
  - class: InitialWorkDirRequirement
    listing: |
      ${
        var output = [];
        for (var i = 0; i < inputs.input_details.length; i++) {
            output.push(inputs.input_details[i]);
        }
        for (var i = 0; i < inputs.input_summaries.length; i++) {
            output.push(inputs.input_summaries[i]);
        }
        return output;
      }