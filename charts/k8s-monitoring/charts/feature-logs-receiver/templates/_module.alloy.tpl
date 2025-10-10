{{- define "feature.logsReceiver.module" }}
declare "logs_receiver" {
  argument "logs_destinations" {
    comment = "Must be a list of logs destinations where collected logs should be forwarded to"
  }

  loki.source.api "default" {
    http {
        listen_address = "0.0.0.0"
        listen_port = {{ .Values.port | quote }}
    }
{{ if .Values.logProcessingRules }}
    forward_to = [loki.relabel.default.receiver]
  }

  loki.relabel "default" {
{{ .Values.logProcessingRules | indent 4 }}
{{- end }}
    forward_to = argument.logs_destinations.value
  }
}
{{- end -}}
