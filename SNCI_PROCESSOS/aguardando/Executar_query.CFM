
<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#application.dsn_processos#">
	INSERT pc_avaliacao_melhorias (
		pc_aval_melhoria_num_aval
		, pc_aval_melhoria_descricao
		, pc_aval_melhoria_num_orgao
		, pc_aval_melhoria_datahora
		, pc_aval_melhoria_login
		, pc_aval_melhoria_sugestao
		, pc_aval_melhoria_sug_orgao_mcu
		, pc_aval_melhoria_naoAceita_justif
		, pc_aval_melhoria_sug_matricula
		, pc_aval_melhoria_status
		, pc_aval_melhoria_sug_datahora)
	VALUES (
	  2505
	, 'a) divulgar, no âmbito da SE/PI, as orientações referentes às regras e controles estabelecidos no normativo interno concernentes ao processo de prestação de contas das AGC;'
	, '00431054'
	,  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
	, '#application.rsUsuarioParametros.pc_usu_login#'
	, ''
	, ''
	, ''
	, '80859992'
	, 'P'
	,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)


	INSERT pc_avaliacao_melhorias (
		pc_aval_melhoria_num_aval
		, pc_aval_melhoria_descricao
		, pc_aval_melhoria_num_orgao
		, pc_aval_melhoria_datahora
		, pc_aval_melhoria_login
		, pc_aval_melhoria_sugestao
		, pc_aval_melhoria_sug_orgao_mcu
		, pc_aval_melhoria_naoAceita_justif
		, pc_aval_melhoria_sug_matricula
		, pc_aval_melhoria_status
		, pc_aval_melhoria_sug_datahora)
	VALUES (
	  2505
	, 'b) certificar por meio de supervisão, e, ou controles complementares, para que não haja ausência ou atrasos na prestação de contas pelas agências vinculadoras;'
	, '00431054'
	,  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
	, '#application.rsUsuarioParametros.pc_usu_login#'
	, ''
	, ''
	, ''
	, '80859992'
	, 'P'
	,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
					 
</cfquery>

