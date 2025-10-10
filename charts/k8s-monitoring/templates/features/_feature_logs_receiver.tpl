{{- define "features.logsReceiver.enabled" }}{{ .Values.logsReceiver.enabled }}{{- end }}

{{- define "features.logsReceiver.collectors" }}
{{- if .Values.logsReceiver.enabled -}}
- {{ .Values.logsReceiver.collector }}
{{- end }}
{{- end }}

{{- define "features.logsReceiver.include" }}
{{- if .Values.logsReceiver.enabled -}}
{{- $destinations := include "features.logsReceiver.destinations" . | fromYamlArray }}
// Feature: Logs Receiver
{{- include "feature.logsReceiver.module" (dict "Values" $.Values.logsReceiver "Files" $.Subcharts.logsReceiver.Files) }}
logs_receiver "feature" {
  logs_destinations = [
    {{ include "destinations.alloy.targets" (dict "destinations" $.Values.destinations "names" $destinations "type" "logs" "ecosystem" "loki") | indent 4 | trim }}
  ]
}
{{- end -}}
{{- end -}}

{{- define "features.logsReceiver.destinations" }}
{{- if .Values.logsReceiver.enabled -}}
{{- include "destinations.get" (dict "destinations" $.Values.destinations "type" "logs" "ecosystem" "pyroscope" "filter" $.Values.logsReceiver.destinations) -}}
{{- end -}}
{{- end -}}

{{- define "features.logsReceiver.destinations.isTranslating" }}
{{- $isTranslating := false -}}
{{- $destinations := include "features.logsReceiver.destinations" . | fromYamlArray -}}
{{ range $destination := $destinations -}}
  {{- $destinationEcosystem := include "destination.getEcosystem" (deepCopy $ | merge (dict "destination" $destination)) -}}
  {{- if ne $destinationEcosystem "loki" -}}
    {{- $isTranslating = true -}}
  {{- end -}}
{{- end -}}
{{- $isTranslating -}}
{{- end -}}

{{- define "features.logsReceiver.collector.values" }}
{{- if .Values.logsReceiver.enabled -}}
{{- $values := dict }}
{{- range $collector := include "features.logsReceiver.collectors" . | fromYamlArray }}
  {{- $extraPorts := deepCopy (dig "alloy" "extraPorts" list (index $.Values $collector)) }}
  {{- if eq (include "collectors.has_extra_port" (deepCopy $ | merge (dict "name" $collector "portNumber" $.Values.logsReceiver.port))) "false" }}
    {{- $extraPorts = append $extraPorts (dict "name" "logs" "port" $.Values.logsReceiver.port "targetPort" $.Values.logsReceiver.port "protocol" "TCP") }}
  {{- end -}}
  {{- $values = $values | merge (dict $collector (dict "alloy" (dict "extraPorts" $extraPorts))) }}
{{- end -}}
{{- $values | toYaml }}
{{- end -}}
{{- end -}}

{{- define "features.logsReceiver.validate" }}
{{- if .Values.logsReceiver.enabled -}}
{{- $featureName := "Logs Receiver" }}
{{- $destinations := include "features.logsReceiver.destinations" . | fromYamlArray }}
{{- include "destinations.validate_destination_list" (dict "destinations" $destinations "type" "logs" "ecosystem" "pyroscope" "feature" $featureName) }}
{{- range $collector := include "features.logsReceiver.collectors" . | fromYamlArray }}
  {{- include "collectors.require_collector" (dict "Values" $.Values "name" $collector "feature" $featureName) }}
  {{- include "collectors.require_extra_port" (dict "Values" $.Values "name" $collector "feature" $featureName "portNumber" $.Values.logsReceiver.port "portName" "logs" "portProtocol" "TCP") }}
{{- end -}}
{{- end -}}
{{- end -}}
