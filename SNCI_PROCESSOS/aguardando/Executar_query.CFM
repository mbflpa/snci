
<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_anexos ADD pc_anexo_enviado bit NOT NULL DEFAULT 0
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	UPDATE pc_anexos SET pc_anexo_enviado = 1
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_avaliacao_posicionamentos ADD pc_aval_posic_enviado bit NOT NULL DEFAULT 0
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	UPDATE pc_avaliacao_posicionamentos SET pc_aval_posic_enviado = 1
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_avaliacao_melhorias ADD pc_aval_melhoria_distribuido bit NOT NULL DEFAULT 0
</cfquery>

<cfquery datasource="#application.dsn_processos#">
    SET IDENTITY_INSERT pc_orientacao_status ON 
    INSERT pc_orientacao_status (pc_orientacao_status_id, pc_orientacao_status_descricao, pc_orientacao_status_status, pc_orientacao_status_comentario, pc_orientacao_status_card_style_header, pc_orientacao_status_card_style_body, pc_orientacao_status_card_style_ribbon, pc_orientacao_status_card_ribbon_nome, pc_orientacao_status_finalizador) VALUES (15, N'JUDICIALIZADO', N'A', N'Na manifestação do gestor é demonstrado que a situação apontada está sendo discutida na esfera judicial.', N'background:rgb(100, 149, 237);color: rgb(255, 255, 255);', N'background:##000;color:##fff;', N'background:##000;color:##fff;', N'JUDICIALIZADO', N'S')
    SET IDENTITY_INSERT pc_orientacao_status OFF 
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_avaliacao_orientacoes ADD pc_aval_orientacao_numProcJudicial varchar(50) null
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_avaliacao_posicionamentos ADD pc_aval_posic_numProcJudicial varchar(50) null
</cfquery>

<cfquery datasource="#application.dsn_processos#">
    SET IDENTITY_INSERT pc_orientacao_status ON 
    INSERT pc_orientacao_status (pc_orientacao_status_id, pc_orientacao_status_descricao, pc_orientacao_status_status, pc_orientacao_status_comentario, pc_orientacao_status_card_style_header, pc_orientacao_status_card_style_body, pc_orientacao_status_card_style_ribbon, pc_orientacao_status_card_ribbon_nome, pc_orientacao_status_finalizador) VALUES (16, N'PONTO SUSPENSO', N'A', N'A solução da situação depende de órgão externo à empresa.', N'background:rgb(189, 149, 237);color: rgb(255, 255, 255);', N'background:##000;color:##fff;', N'background:##000;color:##fff;', N'PONTO SUSPENSO', N'N')
    SET IDENTITY_INSERT pc_orientacao_status OFF 
</cfquery>




