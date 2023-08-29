<!--- <cfmail from="snci@correios.com.br" to="gilvanm@correios.com.br;marceloferreira@correios.com.br" subject="Testando o envio de emails" type="html">
<h1>Boa tarde Marcelo!</h1>
<br>
<h5>Corpo do email</h5>
</cfmail> --->
<cfsetting requesttimeout="15000"> 
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>


<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cffile action="Append" file="#slocal##sarquivo#" output='CodSE;Sigla_SE;Cod_TpUnid;NomeTipoUnid;Pos_Unidade;Nome Unidade;Pos_Inspecao;Pos_NumGrupo;Pos_NumItem;Pos_DtPosic_SOLUCAO;Pos_Situacao_Resp_SOLUCAO;STO_Descricao_SOLUCAO;Pos_username_SOLUCAO;Usu_GrupoAcesso_SOLUCAO;Usu_Apelido_SOLUCAO;Pos_PontuacaoPonto;Pos_ClassificacaoPonto;Pos_Area_SOLUCAO;Pos_NomeArea_SOLUCAO;And_DtPosic_ANTES;And_HrPosic_ANTES;And_Situacao_Resp_ANTES;STO_Descricao_ANTES;And_username_ANTES;Usu_GrupoAcesso_ANTES;Usu_Apelido_ANTES;And_Area_ANTES'>

<cfset PosDtPosic = CreateDate(2023,1,1)>	
<cfquery name="rs3SO" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, Dir_Sigla, Pos_Unidade, Und_Descricao, Und_TipoUnidade, TUN_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp, pos_username, STO_Descricao, Usu_GrupoAcesso, Usu_Apelido, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
FROM (Diretoria INNER JOIN ((Unidades INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo) 
INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) ON Dir_Codigo = Und_CodDiretoria) 
INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
INNER JOIN Usuarios ON pos_username = Usu_Login
WHERE Pos_DtPosic>=#PosDtPosic# and Pos_Situacao_Resp = 3
ORDER BY Diretoria.Dir_Sigla, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
</cfquery>


<cfoutput query="rs3SO">
	<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
	<!--- <cfset AndtHPosic = rs3SO.andHrPosic> --->
	<cfquery name="rsAnd" datasource="#dsn_inspecao#">
		SELECT top 1 And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area, STO_Descricao, Usu_GrupoAcesso, Usu_Apelido
		FROM Andamento INNER JOIN Situacao_Ponto ON And_Situacao_Resp = STO_Codigo
		INNER JOIN Usuarios ON And_username = Usu_Login
		WHERE And_Unidade = '#rs3SO.Pos_Unidade#' AND 
		And_NumInspecao = '#rs3SO.Pos_Inspecao#' AND 
		And_NumGrupo = #rs3SO.Pos_NumGrupo# AND 
		And_NumItem = #rs3SO.Pos_NumItem# AND 
		And_DtPosic <= #PosDtPosic# and
		And_Situacao_Resp <> #rs3SO.Pos_Situacao_Resp#
		order by And_DtPosic desc
	</cfquery>
    <cfif rsAnd.recordcount gt 0>
	<!--- 	<cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Sit_Resp_Antes = '#rsAnd.And_Situacao_Resp#'
			WHERE Pos_Inspecao='#rs3SO.Pos_Inspecao#' and Pos_NumGrupo = #rs3SO.Pos_NumGrupo# and Pos_NumItem = #rs3SO.Pos_NumItem#
		</cfquery> --->
		
		<cfif rs3SO.Pos_Situacao_Resp is 3>
<!--- 			<cfquery name="rsUsu" datasource="#dsn_inspecao#">
				SELECT Usu_GrupoAcesso, Usu_Apelido, Usu_LotacaoNome
				FROM Usuarios
				WHERE Usu_Login = '#pos_username#'
			</cfquery> --->

			<cffile action="Append" file="#slocal##sarquivo#" output='#Und_CodDiretoria#;#Dir_Sigla#;#Und_TipoUnidade#;#TUN_Descricao#;#Pos_Unidade#;#Und_Descricao#;#Pos_Inspecao#;#Pos_NumGrupo#;#Pos_NumItem#;#dateformat(Pos_DtPosic,"dd/mm/yyyy")#;#Pos_Situacao_Resp#;#STO_Descricao#;#pos_username#;#Usu_GrupoAcesso#;#Usu_Apelido#;#Pos_PontuacaoPonto#;#Pos_ClassificacaoPonto#;#Pos_Area#;#Pos_NomeArea#;#dateformat(rsAnd.And_DtPosic,"dd/mm/yyyy")#;#rsAnd.And_HrPosic#;#rsAnd.And_Situacao_Resp#;#rsAnd.STO_Descricao#;#rsAnd.And_username#;#rsAnd.Usu_GrupoAcesso#;#rsAnd.Usu_Apelido#;#rsAnd.And_Area#'>

		</cfif>
	</cfif>
</cfoutput>
<p>Clique na imagem para obter arquivo (.CSV)</p>
<p><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></p>
<p>Fim - Processamento</p>
