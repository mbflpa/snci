
<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#dsn_processos#">
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
	,  CONVERT(char, GETDATE(), 120)
	, '#cgi.REMOTE_USER#'
	, ''
	, ''
	, ''
	, '80859992'
	, 'P'
	,CONVERT(char, GETDATE(), 120))


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
	,  CONVERT(char, GETDATE(), 120)
	, '#cgi.REMOTE_USER#'
	, ''
	, ''
	, ''
	, '80859992'
	, 'P'
	,CONVERT(char, GETDATE(), 120))
					 
</cfquery>

