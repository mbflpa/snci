
<cfprocessingdirective pageencoding = "utf-8">	

<!--Consulta a tabela pc_avaliacao_posicionamentos com where sendo a coluna pc_aval_posic_num_orientacao = 2722 E pc_aval_posic_enviado = 0 -->
<cfquery name="qAvaliacaoPosicionamentos" datasource="#application.dsn_processos#">
    SELECT * FROM pc_avaliacao_posicionamentos WHERE pc_aval_posic_num_orientacao = 2722 AND pc_aval_posic_enviado = 0
</cfquery>
<cfquery name="qAvaliacaoPosicionamentosEnviados" datasource="#application.dsn_processos#">
    SELECT * FROM pc_avaliacao_posicionamentos WHERE pc_aval_posic_num_orientacao = 2722 AND pc_aval_posic_enviado = 1
</cfquery>
<cfquery name="qAnexos" datasource="#application.dsn_processos#">
    SELECT * FROM pc_anexos WHERE pc_anexo_orientacao_id = 2722 and pc_anexo_enviado = 0
</cfquery>
<cfquery name="qAnexosEnviados" datasource="#application.dsn_processos#">
    SELECT * FROM pc_anexos WHERE pc_anexo_orientacao_id = 2722 and pc_anexo_enviado = 1
</cfquery>

<cfdump var = "#qAvaliacaoPosicionamentos#">
<cfdump var = "#qAvaliacaoPosicionamentosEnviados#">
<cfdump var = "#qAnexos#">
<cfdump var = "#qAnexosEnviados#">







